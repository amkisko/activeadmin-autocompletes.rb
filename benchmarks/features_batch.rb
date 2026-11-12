# frozen_string_literal: true

module ActiveAdmin
  module Autocompletes
    module Bench
      module FeaturesBatch
        module_function

        OVERSIZE_QUERY = "  #{"x" * (FilterAutocomplete::MAX_QUERY_CHARS + 40)}  "
        LABEL_PROC = ->(value) { "Label #{value}" }

        # Load axis N: O(N) clamp work without retaining N option hashes.
        # Payload page matches production (at most MAX_LIMIT rows).
        def run!(n)
          limit = FilterAutocomplete.clamp_limit(n)
          query = FilterAutocomplete.clamp_query(OVERSIZE_QUERY)
          offset = [n / 10, 0].max
          clamp_checksum!(n)
          json = JSON.generate(option_page(n:, offset:, limit:))
          shape_input_support!(limit, query)
          json
        end

        def clamp_checksum!(n)
          checksum = 0
          n.times { |i| checksum += FilterAutocomplete.clamp_limit(i + 1) }
          checksum
        end

        def option_page(n:, offset:, limit:)
          remaining = (n - offset).clamp(0, limit)
          Array.new(remaining) do |index|
            i = offset + index
            {"label" => "Item #{i}", "value" => i.to_s}
          end
        end

        def shape_input_support!(limit, query)
          host = input_support_host
          host.options = {
            url: "/admin/things/search_options",
            placeholder: "Find",
            value_field: true,
            multiple: true,
            page_size: limit,
            params: {scope: "active", q: query},
            param_fields: {category_id: "#q_category_id_eq"},
            initial_labels: LABEL_PROC
          }
          values = Array.new(limit) { |i| i.even? ? i.to_s : "" }
          host.public_locals(values)
        end

        def input_support_host
          @input_support_host ||= begin
            template = Object.new
            template.define_singleton_method(:instance_exec) do |*args, &block|
              block.call(*args)
            end

            host = Class.new do
              include ActiveAdmin::Autocompletes::InputSupport

              attr_accessor :options, :template

              def label_from_options = "Label"

              def public_locals(value) = autocomplete_locals(
                object_name: "thing",
                field_name: "code",
                current_value: value
              )
            end.new
            host.template = template
            host
          end
        end
      end
    end
  end
end
