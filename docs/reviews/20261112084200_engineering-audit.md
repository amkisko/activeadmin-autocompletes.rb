# Engineering audit

## Participants

Andrei Makarov (@amkisko)

## Decisions

The review covered the Ruby filter DSL (`FilterAutocomplete`), Formtastic filter/form inputs, Stimulus controller, engine packaging, specs, Pray/AGENTS skills, and the pressure load harness. Pipeline focus: admin GET collection action -> authorize -> clamp limit/offset/query -> host block -> JSON egress; browser Stimulus -> same-origin fetch -> list/chips. Boundary mode treated ActiveAdmin CanCan/Pundit `authorize! :index` and host search blocks as the control surface. Learned-system and physical-actuator checks do not apply.

Findings fixed in this pass:

- Medium (abuse / resource): unbounded `q` could force large host queries. Server clamps query to `MAX_QUERY_CHARS` (200 bytes); Stimulus slices the same bound before fetch.
- Medium (client contract): Stimulus `pageSize` could exceed server `MAX_LIMIT`. Client now clamps limit to `MAX_PAGE_SIZE` (50) to match the Ruby ceiling.
- Low (XSS posture): option and chip labels already use `textContent` (not `innerHTML`); left as-is after review.
- Low (bench harness): `benchmarks/load.rb` restored after propose rewrite breakage; ceilings omit RSS under `process_lifetime`.

Open / deferred:

- Medium (authorization granularity): collection actions always `authorize! :index`. Hosts that need a dedicated autocomplete permission must wrap the block or override; document in host apps if finer auth is required.
- Skip: network as first-party pressure series (Stimulus/fetch excluded from probe; binding marks network `not_in_scope`).

Later pass (same day): Low coverage finding cleared. `spec/dummy` mounts ActiveAdmin; `spec/requests/autocomplete_options_spec.rb` covers options JSON and filter index rendering under the appraisal CI matrix.

Resource and budget: pressure binding at `benchmarks/binding.md`; L1 gate green after cooker episode (see `docs/issues/20261112084200_pressure-cooker-episode.md`). Trace and identification: search queries and selected values stay on same-origin admin sessions; JSON labels are host-controlled.

Stack selection: ActiveAdmin 4 + Rails 7.2+/8.1 peer pattern, Stimulus controller, Formtastic inputs matches preferred-stack. RFCs and docs-conventions prayers are composed into `AGENTS.md`; skills tree includes `engineering-audit`, `pressure-benchmarking`, `preferred-stack`, `rfc-process`.

## Effects

- Original pass: `bundle exec rspec` 4 examples, 0 failures; calibrate + L1 gate (`SAMPLES=5`, `N=25_000`) PASS under `benchmarks/ceilings.json` (RSS not gated); Prayfile wires docs-conventions, preferred-stack, rfc-process, engineering-audit, pressure-benchmarking.
- Later pass: request-level coverage landed via `spec/dummy` + `spec/requests/autocomplete_options_spec.rb`; README states host search blocks must stay indexed and bounded (gem clamps page size and query length only).

## Next

- Medium open: finer authorization than `authorize! :index` stays a host concern unless documented otherwise.
- Network pressure series stays out of scope for the gem probe.

## Source

- `lib/activeadmin/autocompletes/filter_autocomplete.rb`
- `lib/activeadmin/inputs/filters/autocomplete_input.rb`
- `app/assets/controllers/activeadmin_autocompletes/filter_autocomplete_controller.js`
- `spec/requests/autocomplete_options_spec.rb`
- `spec/dummy/app/admin/things.rb`
- `benchmarks/binding.md`
- `docs/issues/20261112084200_pressure-cooker-episode.md`
- `Prayfile`
