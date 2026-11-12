# Engineering audit iteration - activeadmin-autocompletes

## Participants

Andrei Makarov (@amkisko)

## Decisions

Pass 1 audited the options pipeline (collection_action -> authorize -> clamp -> host block -> JSON), Formtastic inputs, Stimulus combobox, engine packaging, and peer-fit gaps from the earlier market scan. Modes: pipeline, product-surface, contracts, security (authz/XSS posture), resource and budget (existing pressure binding), trace and identification (same-origin admin session). Skipped: learned-systems, physical actuators, queue/worker, durable cache (none in gem).

Findings ranked for this gem's product shape (host-owned search, AA4 Stimulus, no Select2/Ransack clone):

1. Medium / missing coverage / contracts: engine smoke only asserts initializer names; importmap pin and view partials are not proven executable. Stage: app packaging. Fix: assert `ActiveAdmin.importmap.packages` key and that autocomplete partials resolve.
2. Medium / incomplete behavior / product-surface: README shows host blocks reading `params[:category_id]`, but the Stimulus client never sends static or sibling-field query params. Stage: ingress (browser) + app logic. Fix: `params:` and `param_fields:` on inputs; merge into fetch URL; clear selection when a watched field changes.
3. Low / redundancy: `_filter_field.html.erb` and `_field.html.erb` nearly duplicate. Stage: maintainability. Fix: one partial.
4. Low / product-surface: single `en` locale for the only UI string; locale parity check already exists. Fix: add `fi` and `sv`.
5. Low / deferred: install generator; finer auth than `authorize! :index`; Tom Select / Ransack batteries DSL (out of product shape).
6. Skip / resource: network Stimulus pressure remains out of scope per binding.

Pass 1 scope for implementation: items 1-4 only.

## Effects

Pass 1 produced this note and the work queue.

Pass 2 (after implementation):

- Finding 1 cleared: engine specs assert importmap package key and partial lookup. Evidence: `bundle exec rspec spec/engine_spec.rb` green.
- Finding 2 cleared: `params:` / `param_fields:` / `page_size:` on inputs; Stimulus `applyExtraParams` + dependency clear. Evidence: request + `input_support` specs; index HTML includes data attributes.
- Finding 3 cleared: single `_field` partial; `_filter_field` removed.
- Finding 4 cleared: `fi`/`sv` locales; `ruby usr/bin/check_locale_parity.rb` -> `Locale parity ok: en, fi, sv (1 keys)`.
- Full suite: `bundle exec rspec` 20 examples, 0 failures; RuboCop clean on touched paths.
- Resource/budget: Ruby clamp path unchanged; no pressure re-gate required (Stimulus network still out of scope).
- Trace: extra query keys are host-declared at render time or read from same-origin form fields; still admin-session only.
- Open: install generator deferred; `authorize! :index` granularity remains host-owned (documented).

## Next

1. Optional install generator if public install friction shows up.
2. Re-run pressure gate only if Ruby options shaping path changes again.
3. Public release blockers stay in `docs/reviews/20261112090000_public-release-readiness.md`.

## Source

- `docs/reviews/20261112084200_engineering-audit.md`
- `docs/issues/20261112085000_support-gaps-vs-peers.md`
- Peer scan: searchable_select, tom_select, ajax_filter (dependent fields)
- `lib/activeadmin/autocompletes/filter_autocomplete.rb`
- `lib/activeadmin/autocompletes/input_support.rb`
- `app/assets/controllers/activeadmin_autocompletes/filter_autocomplete_controller.js`
- `docs/changelogs/20261112134000_params-fields-and-engine-smoke.md`
