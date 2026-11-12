# frozen_string_literal: true

polyrun_cov_measure =
  ENV["POLYRUN_COVERAGE_DISABLE"] != "1" &&
  %w[1 true yes].include?(ENV["POLYRUN_COVERAGE"]&.to_s&.downcase)

if polyrun_cov_measure
  require "coverage"
  branch = %w[1 true yes].include?(ENV["POLYRUN_COVERAGE_BRANCHES"]&.to_s&.downcase)
  ::Coverage.start(lines: true, branches: branch)
end

if polyrun_cov_measure
  require "polyrun/coverage/rails"
  Polyrun::Coverage::Rails.start!(root: File.expand_path("..", __dir__))
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "activeadmin/autocompletes/filter_autocomplete"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end

require "polyrun/rspec_support"
Polyrun::RSpecSupport.install_sharded_formatter_compat!
Polyrun::RSpecSupport.install_failure_fragments!
Polyrun::RSpecSupport.install_worker_ping!
Polyrun::RSpecSupport.install_example_debug!
Polyrun::RSpecSupport.install_example_rails_logging!
Polyrun::RSpecSupport.install_example_timeout!
Polyrun::RSpecSupport.install_example_prosopite!
if %w[1 true yes].include?(ENV["POLYRUN_SPEC_QUALITY"]&.to_s&.downcase)
  Polyrun::RSpecSupport.install_spec_quality!
end
require_relative "support/junit_formatter"
