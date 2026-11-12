# Polyrun RspecJunit.install! shadows ::RSpec (resolved)

## Participants

Andrei Makarov (@amkisko)

## Dependency

polyrun: was 2.2.9; now 3.0.0 (`Gemfile.lock` / appraisal locks: `polyrun (>= 3.0.0)`)

## Symptom

On 2.2.9, `Polyrun::Reporting::RspecJunit.install!` raised `NoMethodError: undefined method 'configure' for module Polyrun::RSpec` when `require "polyrun/rspec"` had already defined `Polyrun::RSpec`. Bare `RSpec.configure` inside `rspec_junit.rb` resolved to `Polyrun::RSpec`, not `::RSpec`.

## Evidence

1. Reproduced under polyrun 2.2.9 with `require "polyrun/rspec"` then `RspecJunit.install!` and `CI=1`.
2. polyrun 3.0.0 CHANGELOG: rename `Polyrun::RSpec` to `Polyrun::RSpecSupport` (`polyrun/rspec_support`); fix `RspecJunit.install!` with `::RSpec` qualification.
3. After bump: `require "polyrun/rspec_support"` then `RspecJunit.install!` registers `::RSpec::Core::Formatters::JsonFormatter`; `POLYRUN_COVERAGE=1 polyrun parallel-rspec --workers 5 --merge-failures` PASS and writes `coverage/merged.json`.

## Suggested fix

Upgrade to polyrun >= 3.0.0; use `Polyrun::RSpecSupport` and restore `RspecJunit.install!` with shard-aware paths. Done in this tree.

## Next

None for this defect.

## Source

- https://github.com/amkisko/polyrun.rb/blob/main/CHANGELOG.md (3.0.0)
- `spec/support/junit_formatter.rb`, `spec/spec_helper.rb`
- `docs/dependencies/20261112161050_polyrun-3-0-0-upgrade.md`
