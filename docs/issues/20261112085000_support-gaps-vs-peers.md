# Support gaps - activeadmin-autocompletes vs upstream path gem + peers

## Participants

Andrei Makarov (@amkisko)

## Decisions

Research compared this gem to the upstream unpublished path gem and peer ActiveAdmin gems under this org. Later pass scoped product-fit improvements from the peer scan: keep host-owned search; add request param wiring instead of a Ransack DSL or Select2/Tom Select dependency.

Remaining must-do:

1. Optional install generator; `pull_request` CI if wanted for public forge.
2. Commit appraisal `gemfiles/*.gemfile.lock` with the first public commit (files already present in tree).

Non-goals: GraphQL autocomplete; host-specific option helper libraries; SQL indexing; Stimulus/network pressure series in gem bench; Ransack batteries-included options DSL; Tom Select UI swap.

## Effects

Fixed earlier pass:

- Stimulus `hasMore` uses clamped `limit` (was `pageSizeValue`).
- Extracted `clamp_limit` / `clamp_query` with specs (including 200-byte truncate).
- README: multi-endpoint `action:`, `params` in blocks, host `authorize! :index`, bounds; host search blocks must stay indexed and bounded (gem clamps page size and query length only).
- Public examples use generic resource names only (no private product details).
- `spec/dummy` + request specs for options JSON and filter index rendering.

Fixed this pass (audit iteration):

- Engine smoke: importmap pin key and field partial resolution.
- Input `params:`, `param_fields:`, `page_size:`; Stimulus merges query keys and clears selection on watched-field change.
- Unified `_field` partial; removed duplicate `_filter_field`.
- Locales `fi` / `sv` for the search placeholder; parity check green.
- Specs: 20 examples green (`bundle exec rspec`).

## Next

1. Optional install generator.
2. Include appraisal lockfiles in the first public commit.
3. Finer authorization than `authorize! :index` remains a host concern unless a later contract adds an action override.

## Source

- Peer: `activeadmin-device_authorization.rb`
- Upstream unpublished path gem under this org
- `docs/reviews/20261112090000_public-release-readiness.md`
- `docs/reviews/20261112133236_engineering-audit-iteration.md`
