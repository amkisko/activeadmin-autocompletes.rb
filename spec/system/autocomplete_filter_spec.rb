# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ActiveAdmin autocomplete filter", type: :system do
  before do
    create(:admin_user, name: "Filter Admin", email: "filter-admin@rails.fi")
    create(:thing, name: "Helsinki Depot", code: "HKI")
    create(:thing, name: "Other Place", code: "OTH")
  end

  it "fetches options through the ActiveAdmin collection_action", :aggregate_failures do
    visit admin_things_path

    expect(page).to have_css('[data-testid="filter-autocomplete-name_eq"]')

    within('[data-testid="filter-autocomplete-name_eq"]') do
      find('[role="combobox"]').click
      find('[role="combobox"]').send_keys("Helsinki")
      expect(page).to have_css('[role="option"]', text: "Helsinki Depot", wait: 5)
      find('[role="option"]', text: "Helsinki Depot").click
      # Without value_field the visible input is the submitted filter value (label text).
      expect(find('[role="combobox"]').value).to eq("Helsinki Depot")
    end
  end

  it "keeps a visible label when value_field submits the id", :aggregate_failures do
    visit admin_things_path

    within('[data-testid="filter-autocomplete-id_eq"]') do
      find('[role="combobox"]').click
      find('[role="combobox"]').send_keys("Helsinki")
      expect(page).to have_css('[role="option"]', text: "Helsinki Depot", wait: 5)
      find('[role="option"]', text: "Helsinki Depot").click
      expect(find('[role="combobox"]').value).to eq("Helsinki Depot")
      expect(find('input[type="hidden"]', visible: :hidden).value).to eq(
        Thing.find_by!(name: "Helsinki Depot").id.to_s
      )
    end
  end
end
