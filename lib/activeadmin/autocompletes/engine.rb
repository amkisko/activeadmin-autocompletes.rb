# frozen_string_literal: true

module ActiveAdmin
  module Autocompletes
    class Engine < ::Rails::Engine
      engine_name "activeadmin_autocompletes"

      initializer "activeadmin_autocompletes.load" do
        require "activeadmin/autocompletes/filter_autocomplete"
        require "activeadmin/autocompletes/input_support"
        require "activeadmin/inputs/filters/autocomplete_input"
        require "activeadmin/inputs/autocomplete_input"
      end

      initializer "activeadmin_autocompletes.assets" do |app|
        assets_path = root.join("app/assets")
        if app.config.respond_to?(:importmap)
          app.config.importmap.cache_sweepers << assets_path.join("controllers")
        end
      end

      initializer "activeadmin_autocompletes.importmap", after: "active_admin.importmap" do
        next unless defined?(ActiveAdmin) && ActiveAdmin.respond_to?(:importmap) && ActiveAdmin.importmap

        ActiveAdmin.importmap.draw do
          pin "controllers/activeadmin_autocompletes/filter_autocomplete_controller",
            to: "activeadmin_autocompletes/filter_autocomplete_controller.js"
        end
      end

      initializer "activeadmin_autocompletes.i18n" do
        I18n.load_path += Dir[root.join("config/locales/*.yml")]
      end

      initializer "activeadmin_autocompletes.view_paths", after: :add_view_paths do
        views_path = root.join("app/views").to_s
        ActiveSupport.on_load(:action_controller) do
          prepend_view_path(views_path)
        end
      end
    end
  end
end
