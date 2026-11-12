# Polyrun RspecJunit.install! shadows ::RSpec

## Participants

Andrei Makarov (@amkisko)

## Dependency

polyrun 2.2.9 (`Gemfile.lock` / appraisal locks: `polyrun (>= 2.2.9)`)

## Symptom

`Polyrun::Reporting::RspecJunit.install!` raises `NoMethodError: undefined method 'configure' for module Polyrun::RSpec` when `require "polyrun/rspec"` has already defined `Polyrun::RSpec`. Bare `RSpec.configure` inside `lib/polyrun/reporting/rspec_junit.rb` resolves to `Polyrun::RSpec`, not `::RSpec`.

## Evidence

1. `require "polyrun/rspec"` then `require "polyrun/reporting/rspec_junit"` then `Polyrun::Reporting::RspecJunit.install!` with `CI=1`.
2. Failure at `RSpec.configure` in `rspec_junit.rb` (polyrun 2.2.9); same source on polyrun.rb main still uses bare `RSpec.configure`.
3. This repo loads `polyrun/rspec` before `spec/support/junit_formatter.rb` in `spec/spec_helper.rb`, so `install!` is unsafe here.

## Suggested fix

Upstream: use `::RSpec.configure` and `::RSpec::Core::Formatters::JsonFormatter` in `RspecJunit.install!`. Workaround here: wire `::RSpec` JSON formatter and call `Polyrun::Reporting::Junit.write_from_json_file` (and CI `polyrun report-junit` for shards).

## Next

Report or PR upstream polyrun; bump when a release includes `::RSpec` qualification.

## Source

- `lib/polyrun/reporting/rspec_junit.rb` in polyrun 2.2.9
- `spec/support/junit_formatter.rb`, `spec/spec_helper.rb` in this repo
