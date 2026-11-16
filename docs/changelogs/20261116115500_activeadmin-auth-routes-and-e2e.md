# ActiveAdmin auth, routes, and e2e

Intent: prove session options follow ActiveAdmin auth and ship Playwright e2e
plus GraphQL admin coexistence without inventing gem routes.

## Participants

Andrei Makarov

## Decisions

Own options exclusively through ActiveAdmin resource `collection_action` paths.
Document that public unauthenticated options are out of gem scope and require
explicit host routes.

## Effects

- Auth request coverage for unauthenticated and authorization-denied options
- Playwright system specs for filter autocomplete and GraphQL admin coexistence
- Non-value_field select keeps the option label in the combobox
- README routes and authentication sections
- CI installs Playwright Chromium for system specs

## Next

Ship as 0.4.0 after green CI on the appraisal matrix.

## Source

- `docs/issues/20261116115500_activeadmin-auth-routes-and-e2e.md`
- CHANGELOG 0.4.0
