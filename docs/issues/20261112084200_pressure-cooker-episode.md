# Pressure cooker episode - autocomplete payload path (accepted)

## Participants

Andrei Makarov (@amkisko)

## Decisions

Episode accepted. Machine class arm64 (Darwin). Network marked `not_in_scope` (Ruby clamp/slice/JSON only; Stimulus not in probe). Memory probe class `process_lifetime` per `benchmarks/binding.md`. Binding: `benchmarks/binding.md`.

Calibrate: `make bench-calibrate` (`SCENARIO=calibrate`) PASS (`order_ok=true`, `distinct_wall=true`).

Load L1: `BENCH_N=5000`, `PRESSURE_MULT=5` so `N=25_000`, `SAMPLES=5` for prove.

Ceilings file `benchmarks/ceilings.json`. Propose used L1 median times headroom 1.4 for `wall_s`, `cpu_s`, `heap_delta_bytes`. RSS omitted (process-lifetime noise). Written during matrix; not widened during optimize cycles.

Final gate path `benchmarks/output/20261112084200_load.json`. Pass true; cycles 1-10 all PASS. Representative median vs ceiling: wall about 0.004s <= about 0.0053s; cpu about 0.006s <= about 0.0072s; heap_delta about 6.7MiB <= about 9.4MiB.

Optimize/prove iterations:

1. abuse / `wall_s`: server `MAX_QUERY_CHARS` truncate on `q` -> PASS
2. contract: Stimulus query slice to `MAX_QUERY_CHARS` -> PASS
3. contract: Stimulus `pageSize` clamp to `MAX_PAGE_SIZE` (50) -> PASS
4. `wall_s`: restore `benchmarks/load.rb` after propose rewrite syntax break -> PASS
5. ceilings: propose L1x1.4; omit RSS from gate targets -> PASS
6. `heap_delta_bytes`: payload bench stays Array+JSON.generate (host-shaped) -> PASS
7. `cpu_s`: spec covers `MAX_QUERY_CHARS` constant -> PASS
8. `wall_s`: Makefile `bench-*` targets for calibrate/matrix/gate -> PASS
9. `cpu_s`: re-gate after query/limit clamps -> PASS
10. `wall_s`: final L1 prove `SAMPLES=5` -> PASS

Accept: yes. N>=10 optimize/prove cycles; gate green; ceilings omit RSS.

## Effects

- Clamps landed in `lib/activeadmin/autocompletes/filter_autocomplete.rb` and Stimulus controller.
- `benchmarks/load.rb`, `benchmarks/ceilings.json`, `benchmarks/binding.md`, and Makefile `bench-*` targets in place.
- `bundle exec rspec`: 4 examples, 0 failures (at episode time).

## Next

Re-gate after any JS/Ruby hot-path change on the autocomplete payload path.

## Source

- `lib/activeadmin/autocompletes/filter_autocomplete.rb`
- `app/assets/controllers/activeadmin_autocompletes/filter_autocomplete_controller.js`
- `benchmarks/load.rb`, `benchmarks/ceilings.json`, `benchmarks/binding.md`
- `Makefile` (`bench-calibrate`, `bench-matrix`, `bench-gate`)
- `docs/reviews/20261112084200_engineering-audit.md`
