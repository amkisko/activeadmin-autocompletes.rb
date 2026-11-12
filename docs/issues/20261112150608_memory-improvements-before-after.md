# Memory improvements with before/after pressure gates

## Participants

Andrei Makarov (@amkisko)

## Decisions

Primary series: `heap_delta_bytes` (Ruby probe). Stimulus DOM window is first-party but outside the Ruby meter (`network` / browser `not_in_scope`). Ceilings re-proposed after the production-shaped bench change; not widened afterward.

Calibrate remained PASS. Machine class arm64 (Darwin). Commands: `SAMPLES=5 SCENARIO=gate bundle exec ruby benchmarks/load.rb` and `SCENARIO=matrix` for propose.

## Effects

Before (episode start, old probe retained N option hashes):

- gate L1 N=25000: wall about 0.0048s, cpu about 0.0066s, heap_delta about 6.7MiB, alloc about 100245
- ceilings: wall 0.0070s, cpu 0.0095s, heap about 9.4MiB

After 1 - production-shaped page allocation in `benchmarks/features_batch.rb` (O(N) clamp, retain <= MAX_LIMIT rows):

- gate vs old ceilings: heap_delta about 36.8KiB, alloc 536 (PASS)
- re-proposed ceilings: wall 0.0037s, cpu 0.0060s, heap about 46.7KiB
- gate vs new ceilings: wall about 0.0027s, heap about 32.6KiB, alloc 402 (PASS)

After 2 - `InputSupport` single-pass option hashes + label cache; `clamp_query` skips `byteslice` when already short:

- before: heap about 32.6KiB, alloc 402
- after: heap about 32.2KiB, alloc 400 (within noise; behavior specs PASS)

After 3 - Stimulus `DocumentFragment` append, `MAX_LIST_ITEMS=100` trim, in-place selected mutate:

- Ruby gate unchanged (browser series not metered)
- final matrix propose: wall 0.0035s, cpu 0.0062s, heap about 49.5KiB
- three L1 proves PASS (heap about 34.5KiB, alloc 412)
- full `bundle exec rspec` PASS

Hot-path re-gate after those edits: calibrate PASS; L1 `SAMPLES=5` PASS (`benchmarks/output/20261112151207_load.json`; wall about 0.0026s, cpu about 0.0042s, heap_delta about 32.2KiB). Dummy host blocks already apply SQL `offset`/`limit` (`Thing.search_options` and admin collection actions). README already states host blocks must stay bounded.

## Next

Stimulus list-window budget stays deferred: no browser meter opened; keep under `benchmarks/binding.md` until a dedicated series is accepted.

## Source

- `benchmarks/features_batch.rb`, `benchmarks/ceilings.json`, `benchmarks/binding.md`
- `lib/activeadmin/autocompletes/input_support.rb`
- `lib/activeadmin/autocompletes/filter_autocomplete.rb`
- `app/assets/controllers/activeadmin_autocompletes/filter_autocomplete_controller.js`
- `spec/dummy/app/models/thing.rb`, `spec/dummy/app/admin/things.rb`
- `benchmarks/output/20261112150425_load.json` (before), `20261112150608_load.json` (memory episode prove), `20261112151207_load.json` (hot-path re-gate)
