# frozen_string_literal: true

require "polyrun/reporting/rspec_junit"

# CI: Polyrun RSpec JSON → JUnit. Parallel workers write tmp/rspec-<shard>.json;
# coverage job merges with `polyrun report-junit -i tmp/rspec-*.json`.
shard = ENV["POLYRUN_SHARD_INDEX"]
Polyrun::Reporting::RspecJunit.install!(
  json_path: shard ? "tmp/rspec-#{shard}.json" : "rspec.json",
  junit_path: shard ? "tmp/junit-#{shard}.xml" : "coverage/junit-coverage.xml"
)
