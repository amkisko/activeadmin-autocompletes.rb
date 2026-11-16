# frozen_string_literal: true

require "rails_helper"

RSpec.describe "activeadmin-graphql coexistence", type: :request do
  it "exposes GraphQL next to ActiveAdmin-owned autocomplete options" do
    admin = create(:admin_user, name: "Api Admin", email: "api-admin@rails.fi")
    sign_in(admin)

    expect(search_options_admin_things_path).to eq("/admin/things/search_options")

    post "/admin/graphql",
      params: {query: "{ __typename }"}.to_json,
      headers: {"CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"}

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to be_present
  end
end
