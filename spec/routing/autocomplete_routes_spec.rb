# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ActiveAdmin autocomplete routes", type: :routing do
  it "owns options under ActiveAdmin.routes with no gem mount line" do
    expect(get: "/admin/things/search_options").to route_to(
      controller: "admin/things",
      action: "search_options"
    )
    expect(get: "/admin/things/code_options").to route_to(
      controller: "admin/things",
      action: "code_options"
    )
    expect(get: "/admin/things/category_item_options").to route_to(
      controller: "admin/things",
      action: "category_item_options"
    )
  end
end
