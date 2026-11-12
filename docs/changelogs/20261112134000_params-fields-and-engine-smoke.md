# Params fields, page size, locales, engine smoke

## Participants

Andrei Makarov (@amkisko)

## Decisions

Ship host-fit extras without becoming a Ransack/Select2 clone: static `params:`, live `param_fields:` CSS selectors, optional `page_size:`, `fi`/`sv` placeholders, engine importmap and view-path smoke specs, single field partial.

## Effects

- Stimulus merges static and sibling-field query keys into options fetches; clears selection when a watched field changes.
- Formtastic filter and form inputs share `InputSupport` and one `_field` partial.
- Engine specs prove importmap pin and partial lookup; request specs cover extra query keys and HTML data contracts.
- Locale parity: `en`, `fi`, `sv`.

## Next

- Optional install generator remains deferred.
- Finer authorization than `authorize! :index` stays host-owned.

## Source

- `docs/reviews/20261112133236_engineering-audit-iteration.md`
- `CHANGELOG.md` Unreleased
