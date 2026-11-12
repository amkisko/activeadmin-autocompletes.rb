# Pressure cooker episode - all Ruby features (accepted)

## Participants

Andrei Makarov (@amkisko)

## Decisions

Episode accepted for the expanded first-party Ruby probe covering clamp, query, offset, payload, and InputSupport. Machine class arm64 (Darwin). Repository revision `f790091` at episode start (bench files changed in-tree during the episode). Network marked `not_in_scope` (Stimulus/fetch excluded). Memory probe class `process_lifetime` per `benchmarks/binding.md`. Formtastic/Rails render stays outside the process probe.

Calibrate: `make bench-calibrate` PASS (`order_ok=true`, `distinct_wall=true` for stages `clamp`, `query`, `offset`, `payload`, `input_support`).

Load: L0 `BENCH_N=5000`, L1 `N=25000` (`PRESSURE_MULT=5`), `SAMPLES=5` for propose and prove.

Ceilings: `benchmarks/ceilings.json` proposed from L1 median times headroom 1.4 (`wall_s` about 0.0070s, `cpu_s` about 0.0095s, `heap_delta_bytes` about 9.4MiB). RSS omitted. Not widened during optimize cycles.

Final prove artifact: `benchmarks/output/20261112144852_load.json` (pass true). Representative median vs ceiling: wall about 0.0045s, cpu about 0.0065s, heap_delta about 6.7MiB.

Optimize/prove iterations:

1. `wall_s`: expand batch to call `FilterAutocomplete.clamp_limit` / `clamp_query` (was Integer#clamp only) -> PASS
2. `cpu_s`: add InputSupport locals/params/param_fields/page_size/chips to the same L1 batch -> PASS
3. `heap_delta_bytes`: split `benchmarks/features_batch.rb` and memoize InputSupport host -> PASS
4. `wall_s`: freeze oversize query string as `OVERSIZE_QUERY` -> PASS
5. `heap_delta_bytes`: share `LABEL_PROC` constant for chip labels -> PASS
6. contract: rewrite `benchmarks/binding.md` for five stages and feature list -> PASS
7. ceilings: re-matrix propose L1x1.4 after expanded probe -> PASS
8. `wall_s`: L1 gate prove `SAMPLES=5` -> PASS
9. `cpu_s`: L1 gate prove `SAMPLES=5` -> PASS
10. `wall_s`: final L1 prove `SAMPLES=5` -> PASS

Accept: yes. N>=10; gate green on all three gated series; no remaining high-confidence first-party candidates above noise; Stimulus network still out of scope.

## Effects

- Probe now exercises all Ruby hot paths named in the binding.
- `benchmarks/load.rb`, `benchmarks/features_batch.rb`, `benchmarks/ceilings.json`, and `benchmarks/binding.md` updated.
- Ten consecutive L1 gates PASS under the new ceilings.
- Later hot-path edits (production-shaped payload page, InputSupport single-pass, `clamp_query` short-circuit) re-gated PASS under post-memory ceilings (`benchmarks/output/20261112151207_load.json`). Detail: `docs/issues/20261112150608_memory-improvements-before-after.md`.

## Next

Stimulus/network pressure remains out of scope until a separate binding opens that series (see `benchmarks/binding.md`).

## Source

- `benchmarks/load.rb`, `benchmarks/features_batch.rb`, `benchmarks/ceilings.json`, `benchmarks/binding.md`
- `benchmarks/output/20261112144849_load.json` (matrix), `20261112144852_load.json` (episode prove), `20261112151207_load.json` (hot-path re-gate)
- `lib/activeadmin/autocompletes/filter_autocomplete.rb`
- `lib/activeadmin/autocompletes/input_support.rb`
- `docs/issues/20261112084200_pressure-cooker-episode.md` (prior payload-only episode)
- `docs/issues/20261112150608_memory-improvements-before-after.md`
