# CHANGELOG

## 0.3.0 (2026-11-12)

- Add `params:` and `param_fields:` on autocomplete inputs so options requests can carry static keys and live sibling-field values
- Clear the current selection when a watched `param_fields` source changes
- Add optional `page_size:` on inputs (clamped to 1..50)
- Add `fi` and `sv` placeholders for the search field
- Prove importmap pin and field partial resolution in engine specs
- Extract ActiveAdmin lazy autocomplete (filters, form inputs, Stimulus typeahead, multi-select chips) into a standalone gem
- Add multi-select chips mode (`multiple: true`) for form and filter autocomplete inputs
- Clamp option `limit` to 1..50 and query string to 200 bytes (server and Stimulus)
- Align Stimulus `hasMore` pagination with the clamped page size
- Document host `authorize! :index` contract and multi-endpoint `action:` / `params` usage
- Pressure binding and L1 load ceilings for the Ruby payload shaping path
- Rails dummy + request specs for autocomplete options endpoints and filter index rendering
