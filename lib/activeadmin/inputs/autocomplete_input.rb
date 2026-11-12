# frozen_string_literal: true

require "activeadmin/autocompletes/input_support"

module ActiveAdmin
  module Inputs
    class AutocompleteInput < ::Formtastic::Inputs::StringInput
      include ActiveAdmin::Autocompletes::InputSupport

      def to_html
        input_wrapping do
          label_html << template.render(
            PARTIAL,
            **autocomplete_locals(
              object_name: builder.object_name,
              field_name: method,
              current_value: current_value
            )
          )
        end
      end

      private

      def current_value
        return options[:selected] if options.key?(:selected)

        object.public_send(method) if object.respond_to?(method)
      rescue NoMethodError
        nil
      end
    end
  end
end
