# frozen_string_literal: true

ActiveAdmin.register Thing do
  extend ActiveAdmin::Autocompletes::FilterAutocomplete

  permit_params :name, :code

  filter_autocomplete :search do |query:, limit:, offset:|
    Thing.search_options(query:, limit:, offset:)
  end

  filter_autocomplete :code, action: :code_options do |query:, limit:, offset:|
    scope = Thing.order(:code)
    scope = scope.where("code LIKE ?", "%#{Thing.sanitize_sql_like(query)}%") if query.present?
    scope.offset(offset).limit(limit).map do |thing|
      {"label" => thing.code, "value" => thing.id.to_s}
    end
  end

  filter_autocomplete :category_items, action: :category_item_options do |query:, limit:, offset:|
    category_id = params[:category_id].presence
    next [] if category_id.blank?

    scope = Thing.order(:name).where(code: category_id)
    scope = scope.where("name LIKE ?", "%#{Thing.sanitize_sql_like(query)}%") if query.present?
    scope.offset(offset).limit(limit).map do |thing|
      {"label" => thing.name, "value" => thing.id.to_s}
    end
  end

  filter :name_eq,
    as: :autocomplete,
    label: "Name",
    url: -> { search_options_admin_things_path }

  filter :id_eq,
    as: :autocomplete,
    value_field: true,
    label: "Thing",
    url: -> { search_options_admin_things_path },
    initial_label: ->(id) { Thing.find_by(id: id)&.name.to_s }

  filter :code_eq,
    as: :autocomplete,
    value_field: true,
    label: "Code scoped",
    url: -> { category_item_options_admin_things_path },
    page_size: 10,
    params: {scope: "active"},
    param_fields: {category_id: "#q_name_eq"},
    initial_label: ->(id) { Thing.find_by(id: id)&.name.to_s }

  index do
    column :id
    column :name
    column :code
  end
end
