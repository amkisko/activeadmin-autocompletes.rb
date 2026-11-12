# frozen_string_literal: true

require "activeadmin/autocompletes/input_support"

module ActiveAdmin
  module Inputs
    module Filters
      class AutocompleteInput < ::Formtastic::Inputs::StringInput
        include Base
        include ActiveAdmin::Autocompletes::InputSupport

        def to_html
          input_wrapping do
            label_html << template.render(
              PARTIAL,
              **autocomplete_locals(
                object_name: builder.object_name,
                field_name: input_name,
                current_value: current_value
              )
            )
          end
        end

        def input_name
          method
        end

        private

        def current_value
          @object.public_send(method).presence if @object.respond_to?(method)
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
