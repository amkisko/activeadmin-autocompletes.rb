# activeadmin-autocompletes

[![Test Status](https://github.com/amkisko/activeadmin-autocompletes.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/activeadmin-autocompletes.rb/actions/workflows/test.yml)

ActiveAdmin-only support for lazy and extensible, fully configurable autocompletes for filters and inputs. Session REST JSON options, Formtastic filter/form inputs, Stimulus typeahead, and multi-select chips.

## Requirements

- Ruby 3.4+
- Rails 7.2.3.2+
- ActiveAdmin 4.0.0.beta23+

## Install

From RubyGems after a release:

```ruby
# Gemfile
gem "activeadmin-autocompletes"
```

From git:

```ruby
# Gemfile
gem "activeadmin-autocompletes", github: "amkisko/activeadmin-autocompletes.rb"
```

## Usage

```ruby
ActiveAdmin.register Thing do
  extend ActiveAdmin::Autocompletes::FilterAutocomplete

  # Default action name: :search_options → search_options_admin_things_path
  filter_autocomplete :search do |query:, limit:, offset:|
    Thing.search_options(query:, limit:, offset:)
  end

  # Extra endpoints: pass action: and use params from the request
  filter_autocomplete :category_items, action: :category_item_options do |query:, limit:, offset:|
    Item.search_options(query:, limit:, offset:, category_id: params[:category_id])
  end

  filter :city_eq,
    as: :autocomplete,
    label: "City",
    url: -> { search_options_admin_things_path }

  # Association id filter: hidden submitted id, visible label
  filter :company_id_eq,
    as: :autocomplete,
    value_field: true,
    label: "Company",
    url: -> { search_options_admin_companies_path },
    initial_label: ->(id) { Company.find_by(id: id)&.name.to_s }

  # Static query params plus live sibling fields (CSS selectors)
  filter :item_id_eq,
    as: :autocomplete,
    value_field: true,
    label: "Item",
    url: -> { category_item_options_admin_things_path },
    page_size: 10,
    params: {scope: "active"},
    param_fields: {category_id: "#q_category_id_eq"},
    initial_label: ->(id) { Item.find_by(id: id)&.name.to_s }

  # Multi-select chips on forms (and filters when multiple: true)
  form do |f|
    f.input :tag_ids,
      as: :autocomplete,
      multiple: true,
      value_field: true,
      url: -> { search_options_admin_tags_path },
      initial_labels: ->(id) { Tag.find_by(id: id)&.name.to_s }
  end
end
```

Options endpoint must return JSON `[{ "label" => "...", "value" => "..." }, ...]` (optional `id` is accepted as the submitted value).

Input options:

- `params:` - hash or callable; merged into every options request as query keys
- `param_fields:` - hash of query key => CSS selector; live values read from those fields on each fetch; changing a watched field clears the current selection
- `page_size:` - client page size (clamped to 1..50, default 20)

### Authorization and bounds

Every options `collection_action` calls `authorize! :index, config.resource_class`. Hosts that need a finer permission must wrap the block or authorize in the host policy for `index?` on that resource.

Server clamps `limit` to 1..50 and `q` to 200 bytes. The Stimulus controller applies the same page-size and query bounds and uses the clamped limit for `hasMore` pagination. Host search blocks must stay indexed and bounded themselves; the gem does not rewrite queries or add indexes.

## Assets

The engine pins the Stimulus controller on `ActiveAdmin.importmap`. Host should watch:

```ruby
ActiveAdmin::Autocompletes::Engine.root.join("app/assets")
```

## Development

```bash
bundle install
bundle exec appraisal install
make test
```

Maintainers publish with `make release` (`usr/bin/release.rb`).
