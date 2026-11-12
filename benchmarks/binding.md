# Pressure binding — activeadmin-autocompletes

## Measure

```sh
SCENARIO=gate bundle exec ruby benchmarks/load.rb
# or: make bench-gate
```

## Self-test (calibrate)

```sh
SCENARIO=calibrate bundle exec ruby benchmarks/load.rb
# or: make bench-calibrate
```

Distinct stages: `clamp`, `query`, `offset`, `payload`, `input_support`. Fail if stage order or wall separation collapses.

## Features under probe

Ruby first-party hot paths only:

- `FilterAutocomplete.clamp_limit` / `clamp_query`
- option-row offset slice and JSON payload shaping
- `InputSupport` locals (params, param_fields, page_size, selected chips, labels)

Stimulus / fetch marked `not_in_scope` (network). Formtastic/Rails render stays out of the process probe.

## Ceilings

`benchmarks/ceilings.json` — propose from L1 median × headroom `1.4` for `wall_s`, `cpu_s`, `heap_delta_bytes`. RSS omitted (`process_lifetime` noise).

## Load axis

- `N` — clamp iterations plus virtual catalog size for offset/page math per sample
- Payload page retains at most `MAX_LIMIT` option hashes (production-shaped); do not retain N hashes
- L0 default `N=5_000` (`BENCH_N`)
- L1 default `N=25_000` (`PRESSURE_MULT≈5`)

## Samples

- `SAMPLES` default `3` (gate / propose / write); use `>=5` for prove when tightening

## Episode iterations

- `N_ITER` default `10` (optimize → prove)

## Propose basis

- timing / heap: L1 median × headroom `1.4`
- `TARGET_FACTOR` reserved for later tighten-only passes
- do not gate on RSS deltas under `process_lifetime`

## Memory probe class

`process_lifetime`

## Network

`not_in_scope` (pure Ruby clamp/slice/payload/InputSupport; Stimulus/fetch not in probe)

## Browser list window

Stimulus keeps at most `MAX_LIST_ITEMS` (100) option DOM nodes while scrolling. That series is not in the Ruby pressure probe and has no accepted browser meter yet. Do not gate CI on list-window memory until a separate binding names the probe, load axis, and ceilings.
