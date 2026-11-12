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

Distinct stages: `clamp`, `offset`, `payload`. Fail if stage order or wall separation collapses.

## Ceilings

`benchmarks/ceilings.json` — propose from L1 median × headroom `1.4` for `wall_s`, `cpu_s`, `heap_delta_bytes`. RSS omitted (`process_lifetime` noise).

## Load axis

- `N` — number of option rows synthesized / clamped / offset-sliced per sample
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

`not_in_scope` (pure Ruby clamp/slice/payload shaping; Stimulus/fetch not in probe)
