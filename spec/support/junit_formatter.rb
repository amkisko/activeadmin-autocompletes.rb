# frozen_string_literal: true

require "polyrun/reporting/junit"

# CI: Polyrun JUnit export from RSpec JSON.
# Parallel workers write tmp/rspec-<shard>.json; coverage job merges with
# `polyrun report-junit -i tmp/rspec-*.json`.
#
# Do not call Polyrun::Reporting::RspecJunit.install! after require "polyrun/rspec":
# bare `RSpec.configure` inside that helper resolves to Polyrun::RSpec (see docs/dependencies).
if ENV["CI"]
  require "fileutils"
  require "rspec/core"
  require "rspec/core/formatters/json_formatter"

  shard = ENV["POLYRUN_SHARD_INDEX"]
  json_path = File.expand_path(shard ? "../../tmp/rspec-#{shard}.json" : "../../rspec.json", __dir__)
  FileUtils.mkdir_p(File.dirname(json_path))

  ::RSpec.configure do |config|
    config.add_formatter(::RSpec::Core::Formatters::JsonFormatter, json_path)
  end

  unless shard
    at_exit do
      next unless File.file?(json_path)

      FileUtils.mkdir_p(File.expand_path("../../coverage", __dir__))
      Polyrun::Reporting::Junit.write_from_json_file(
        json_path,
        output_path: File.expand_path("../../coverage/junit-coverage.xml", __dir__)
      )
    end
  end
end
