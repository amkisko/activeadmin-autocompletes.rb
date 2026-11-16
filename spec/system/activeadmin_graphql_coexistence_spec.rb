# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Autocomplete with activeadmin-graphql", type: :system do
  before do
    create(:admin_user, name: "Graph Admin", email: "graph-admin@rails.fi")
    create(:thing, name: "Graph Thing", code: "GT")
  end

  it "boots ActiveAdmin with GraphQL and keeps autocomplete interactive", :aggregate_failures do
    visit admin_things_path

    expect(page).to have_css('[data-testid="filter-autocomplete-name_eq"]')

    payload = page.driver.with_playwright_page do |browser_page|
      # Quoted delimiter keeps JS `${}` from Ruby interpolation.
      browser_page.evaluate(<<~'JS') # rubocop:disable Style/RedundantHeredocDelimiterQuotes
        async () => {
          const response = await fetch("/admin/graphql", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
            },
            credentials: "same-origin",
            body: JSON.stringify({ query: "{ __typename }" })
          })
          return { status: response.status, body: await response.json() }
        }
      JS
    end

    expect(payload.fetch("status")).to eq(200)
    expect(payload.dig("body", "data")).to be_present

    within('[data-testid="filter-autocomplete-name_eq"]') do
      find('[role="combobox"]').click
      find('[role="combobox"]').send_keys("Graph")
      expect(page).to have_css('[role="option"]', text: "Graph Thing", wait: 5)
    end
  end
end
