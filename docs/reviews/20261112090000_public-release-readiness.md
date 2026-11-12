# Public release readiness - activeadmin-autocompletes

## Participants

Andrei Makarov (@amkisko)

## Decisions

Verdict: not ready for public release. Repos stay private; no commit yet. Release prep advanced: lint green, dated CHANGELOG, appraisal locks, Rails/ActiveAdmin request specs, pressure PASS. Remaining forge blockers: empty git history and private visibility (intentional until opened).

Ready (present):

- RubyGems name `activeadmin-autocompletes` is free (API 404).
- `gem build` succeeds; package includes engine, inputs, Stimulus controller, partials, locales, sig, community docs.
- No private-product names in public README/docs after scrub.
- Community docs present; gemspec pins ActiveAdmin 4 + Rails + importmap-rails; `allowed_push_host` rubygems.org.
- Specs: unit + `spec/dummy` request coverage for options JSON endpoints and index filter rendering (13 examples green).
- Pressure L1 gate: PASS.
- Stimulus `hasMore` aligned with clamped limit; README covers multi-endpoint, `authorize! :index`, bounds.

Blockers (must clear before public cut):

- High: no commits; GitHub default branch empty (`git status`; `gh` empty `defaultBranchRef`).
- High: repository is private (`gh repo view` visibility PRIVATE).
- Medium: fully untracked tree; release clean-tree gate fails (`usr/bin/release.rb`).

Should before or with first public 0.3.0: commit, push, set visibility for the public story.

Non-blockers for a first 0.x:

- Single `en` locale (peer device_authorization has three; optional).
- No install generator (host Gemfile + importmap watch is documented).
- Browser/Stimulus not in pressure probe (`network: not_in_scope`).

## Effects

- `make release` cannot succeed today (Unreleased, lint, dirty tree, appraisal discipline).
- Shipping to RubyGems with an empty private GitHub repo breaks the documented source/homepage URIs.

## Next

1. Commit/push + visibility decision.
2. Pressure re-gate after any JS/Ruby hot-path change; then `make release`.

## Source

- `usr/bin/release.rb`, `CHANGELOG.md`, `activeadmin-autocompletes.gemspec`
- `gh repo view amkisko/activeadmin-autocompletes.rb`
- `docs/reviews/20261112084200_engineering-audit.md`
- `docs/issues/20261112085000_support-gaps-vs-peers.md`
- Peer: `activeadmin-device_authorization.rb`
