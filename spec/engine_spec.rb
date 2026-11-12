# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Autocompletes::Engine do
  it "registers load, assets, importmap, i18n, and view path initializers" do
    names = described_class.initializers.map(&:name)
    expect(names).to include(
      "activeadmin_autocompletes.load",
      "activeadmin_autocompletes.assets",
      "activeadmin_autocompletes.importmap",
      "activeadmin_autocompletes.i18n",
      "activeadmin_autocompletes.view_paths"
    )
  end

  it "pins the Stimulus controller on ActiveAdmin.importmap" do
    expect(ActiveAdmin.importmap).to be_present
    expect(ActiveAdmin.importmap.packages).to include(
      "controllers/activeadmin_autocompletes/filter_autocomplete_controller"
    )
  end

  it "resolves autocomplete field partials on the view path" do
    controller = ActionController::Base.new
    expect(controller.lookup_context.exists?("active_admin/autocompletes/field", [], true)).to be(true)
  end
end
