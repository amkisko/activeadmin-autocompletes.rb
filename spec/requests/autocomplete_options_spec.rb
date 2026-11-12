# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ActiveAdmin autocomplete options", type: :request do
  it "returns JSON options for the default search endpoint" do
    match = Thing.create!(name: "Helsinki Depot", code: "HKI")
    Thing.create!(name: "Other Place", code: "OTH")

    get search_options_admin_things_path, params: {q: "Helsinki", limit: 10}, as: :json

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to contain_exactly(
      hash_including("label" => match.name, "value" => match.id.to_s)
    )
  end

  it "supports a second collection_action endpoint" do
    Thing.create!(name: "Alpha", code: "ZZ-9")

    get code_options_admin_things_path, params: {q: "ZZ", limit: 5}, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.first).to include("label" => "ZZ-9")
  end

  it "passes host query params into the options block" do
    match = Thing.create!(name: "Scoped Match", code: "CAT-1")
    Thing.create!(name: "Other", code: "CAT-2")

    get category_item_options_admin_things_path,
      params: {q: "Scoped", category_id: "CAT-1", limit: 10},
      as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to contain_exactly(
      hash_including("label" => match.name, "value" => match.id.to_s)
    )
  end

  it "returns an empty list when a required host param is missing" do
    Thing.create!(name: "Scoped Match", code: "CAT-1")

    get category_item_options_admin_things_path, params: {q: "Scoped", limit: 10}, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq([])
  end

  it "clamps oversized limits and blank queries" do
    3.times { |i| Thing.create!(name: "Item #{i}", code: "C#{i}") }

    get search_options_admin_things_path, params: {limit: 10_000, q: "   "}, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.size).to eq(3)
  end

  it "renders the index with autocomplete filters and extra param contracts" do
    Thing.create!(name: "Visible Thing", code: "VT")

    get admin_things_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Visible Thing")
    expect(response.body).to include("activeadmin-autocompletes--filter-autocomplete")
    expect(response.body).to include('data-activeadmin-autocompletes--filter-autocomplete-page-size-value="10"')
    expect(response.body).to include("data-activeadmin-autocompletes--filter-autocomplete-params-value=")
    expect(response.body).to include("&quot;scope&quot;:&quot;active&quot;")
    expect(response.body).to include("data-activeadmin-autocompletes--filter-autocomplete-param-fields-value=")
    expect(response.body).to include("&quot;category_id&quot;:&quot;#q_name_eq&quot;")
  end

  it "renders new and edit forms with autocomplete inputs" do
    thing = Thing.create!(name: "Editable Thing", code: "ED")

    get new_admin_thing_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("activeadmin-autocompletes--filter-autocomplete")
    expect(response.body).to include("thing[name]")
    expect(response.body).to include("thing[code][]")

    get edit_admin_thing_path(thing)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Editable Thing")
    expect(response.body).to include("activeadmin-autocompletes--filter-autocomplete")
  end
end
