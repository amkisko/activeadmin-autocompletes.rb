# ActiveAdmin auth, routes, and e2e

## Participants

Andrei Makarov

## Decisions

Keep options on resource `collection_action` under `ActiveAdmin.routes` so hosts
need no autocomplete line in `routes.rb`. Auth follows ActiveAdmin
`authentication_method` plus `authorize! :index`. Do not auto-mount public
options; public JSON search stays a host `routes.rb` declaration outside this
gem. Add Capybara Playwright system specs and GraphQL admin coexistence smoke.

## Effects

- Dummy enables `authentication_method` / `current_user_method` and GraphQL.
- Request specs cover 401 for signed-out and adapter-deny paths.
- System specs cover filter typeahead and GraphQL fetch beside autocomplete.
- README documents zero-line routes and auth contract.

## Next

1. Confirm Playwright Chromium on CI after workflow Node setup lands.
2. Ship 0.4.0 after green appraisal matrix.
3. Optional later: escape-hatch `Routes.draw` only if a shared non-resource
   options controller is needed (not required for collection_action).

## Source

- `docs/changelogs/20261116115500_activeadmin-auth-routes-and-e2e.md`
- CHANGELOG 0.4.0
