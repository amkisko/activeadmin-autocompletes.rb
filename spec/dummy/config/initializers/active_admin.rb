# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_user
  config.site_title = "Autocompletes Dummy"
  config.logout_link_path = false
  config.comments = false

  config.namespace :admin do |admin|
    admin.graphql = true
  end
end

# Stimulus boot for system specs: ActiveAdmin.importmap entry loads AA JS then
# registers the autocomplete controller (host apps do the same via their layout).
ActiveAdmin.importmap.draw do
  pin "@hotwired/stimulus", to: "stimulus.min.js"
  pin "active_admin_autocompletes_boot", to: "active_admin_autocompletes_boot.js"
end
