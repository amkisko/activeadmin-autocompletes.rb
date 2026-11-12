#!/usr/bin/env ruby
# frozen_string_literal: true

# Pressure / load bench for ActiveAdmin Autocompletes Ruby hot paths:
# limit/query clamp, offset slice, JSON option payload, InputSupport shaping.
#
# Usage:
#   SCENARIO=calibrate bundle exec ruby benchmarks/load.rb
#   SCENARIO=gate bundle exec ruby benchmarks/load.rb
#   SCENARIO=matrix bundle exec ruby benchmarks/load.rb

gem_lib = File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift(gem_lib) unless $LOAD_PATH.include?(gem_lib)

polyrun_lib = ENV["PRESSURE_POLYRUN_LIB"] || File.expand_path("../../polyrun.rb/lib", __dir__)
$LOAD_PATH.unshift(polyrun_lib) unless $LOAD_PATH.include?(polyrun_lib)

require "json"
require "activeadmin/autocompletes/filter_autocomplete"
require "activeadmin/autocompletes/input_support"
require "polyrun/benchmark/pressure"
require_relative "features_batch"

module ActiveAdmin
  module Autocompletes
    module Bench
      module Load
        module_function

        STAGES = %w[clamp query offset payload input_support].freeze

        def run!
          scenario = ENV.fetch("SCENARIO", "matrix")
          samples = env_int("SAMPLES", 3)
          n0 = env_int("BENCH_N", 5_000)
          pressure_mult = env_float("PRESSURE_MULT", 5.0)
          factor = env_float("TARGET_FACTOR", Polyrun::Benchmark::Pressure::DEFAULT_TARGET_FACTOR)

          case scenario
          when "calibrate"
            exit calibrate! ? 0 : 1
          when "gate"
            results = gate!(n1: (n0 * pressure_mult).round, samples: samples)
          when "matrix", "smoke"
            n = (scenario == "smoke") ? 500 : n0
            results = matrix!(n0: n, pressure_mult: pressure_mult, factor: factor, samples: samples)
          else
            raise ArgumentError, "Unknown SCENARIO=#{scenario.inspect}"
          end

          path = Polyrun::Benchmark::Pressure.write_results!(
            results,
            repository_root: File.expand_path("..", __dir__),
            name: "load"
          )
          results.each { |row| puts row["report"] }
          puts "wrote #{path}"
          exit(results.any? { |row| row["pass"] == false } ? 1 : 0)
        end

        def calibrate!
          walls = {}
          STAGES.each_with_index do |stage, index|
            sleep_s = 0.01 * (index + 1)
            before = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            sleep sleep_s
            walls[stage] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - before
          end
          order_ok = walls.values.each_cons(2).all? { |a, b| b > a }
          distinct_wall = walls.values.uniq.size == walls.size
          puts({order_ok: order_ok, distinct_wall: distinct_wall, walls: walls}.to_json)
          order_ok && distinct_wall
        end

        def matrix!(n0:, pressure_mult:, factor:, samples:)
          results = []
          baseline = median_sample("baseline_features", n0, samples) { FeaturesBatch.run!(n0) }
          results << baseline
          n1 = [(n0 * pressure_mult).round, 1].max
          pressure = median_sample("pressure_features_#{n1}", n1, samples) { FeaturesBatch.run!(n1) }
          results << pressure
          propose_ceilings!(pressure, factor: factor)
          results
        end

        def gate!(n1:, samples:)
          ceilings = load_ceilings
          [median_sample("gate_features_#{n1}", n1, samples, targets: ceilings) { FeaturesBatch.run!(n1) }]
        end

        def median_sample(label, ops, samples, targets: nil)
          rows = Array.new(samples) do
            Polyrun::Benchmark::Pressure.measure(label: label, ops: ops, extras: {"targets" => targets}) { yield }
          end
          pick_median(rows)
        end

        def pick_median(rows)
          sorted = rows.sort_by { |row| row.dig("metrics", "wall_s").to_f }
          sorted[sorted.size / 2]
        end

        def propose_ceilings!(pressure_row, factor:, headroom: 1.4)
          metrics = pressure_row.fetch("metrics")
          ceilings = {
            "wall_s" => metrics["wall_s"] * headroom,
            "cpu_s" => metrics["cpu_s"] * headroom,
            "heap_delta_bytes" => [metrics["heap_delta_bytes"] * headroom, 0].max
          }
          path = File.expand_path("ceilings.json", __dir__)
          File.write(path, JSON.pretty_generate(ceilings))
          puts "proposed ceilings -> #{path} (headroom=#{headroom}; factor=#{factor} reserved for tighten; rss omitted)"
          ceilings
        end

        def load_ceilings
          path = File.expand_path("ceilings.json", __dir__)
          return nil unless File.file?(path)

          JSON.parse(File.read(path))
        end

        def env_int(name, default)
          Integer(ENV.fetch(name, default))
        end

        def env_float(name, default)
          Float(ENV.fetch(name, default))
        end
      end
    end
  end
end

ActiveAdmin::Autocompletes::Bench::Load.run!
