# Testing

## Commands

```bash
bundle install
npx -y "playwright@$(tr -d '[:space:]' < .playwright-version)" install chromium
bundle exec rspec
# or
make test
```

System specs skip when the Playwright CLI is unavailable.

## Layout

- `spec/` unit and DSL specs
- `spec/requests` options JSON, auth, GraphQL coexistence
- `spec/routing` ActiveAdmin-owned collection_action paths
- `spec/system` Capybara Playwright e2e (filter select, GraphQL beside autocomplete)
- `spec/dummy/` minimal Rails app with ActiveAdmin auth and GraphQL enabled

## Guidelines

- Test executable behavior and host-facing contracts.
- Options auth follows ActiveAdmin `authentication_method` and `authorize! :index`.
- Coverage threshold: `config/polyrun_coverage.yml`.
