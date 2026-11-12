# frozen_string_literal: true

class Thing < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name code created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.search_options(query:, limit:, offset:)
    scope = order(:name)
    scope = scope.where("name LIKE ?", "%#{sanitize_sql_like(query)}%") if query.present?
    scope.offset(offset).limit(limit).map do |thing|
      {"label" => thing.name, "value" => thing.id.to_s}
    end
  end
end
