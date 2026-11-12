# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module ActiveAdmin
  module Autocompletes
    module InputSupport
      CONTROLLER = "activeadmin-autocompletes--filter-autocomplete"
      PARTIAL = "active_admin/autocompletes/field"

      private

      def autocomplete_search_url
        url = options[:url]
        url = template.instance_exec(&url) if url.respond_to?(:call)
        url.to_s
      end

      def autocomplete_placeholder
        options[:placeholder].presence || I18n.t(
          "active_admin.autocompletes.filter_placeholder",
          default: "Type to search"
        )
      end

      def value_field?
        options[:value_field].present?
      end

      def multiple?
        options[:multiple].present?
      end

      def page_size_value
        raw = options[:page_size]
        return if raw.blank?

        FilterAutocomplete.clamp_limit(raw)
      end

      def static_params
        raw = options[:params]
        return {} if raw.blank?

        hash = raw.respond_to?(:call) ? template.instance_exec(&raw) : raw
        stringify_option_hash(hash, keep_nil: true)
      end

      def param_fields
        raw = options[:param_fields]
        return {} if raw.blank?

        stringify_option_hash(raw, keep_nil: false)
      end

      def selected_items_for(current_value)
        return [] unless multiple?

        labels = options[:initial_labels]
        Array(current_value).filter_map do |value|
          next if value.blank?

          {value: value, label: label_for_value(value, labels)}
        end
      end

      def stringify_option_hash(raw, keep_nil:)
        out = {}
        raw.to_h.each do |key, value|
          out[key.to_s] = keep_nil ? value&.to_s : value.to_s
        end
        out
      end

      def initial_label_for(current_value)
        label = options[:initial_label]
        return "" if current_value.blank? && label.blank?

        label_for_value(current_value, label)
      end

      def label_for_value(value, labels)
        resolved = if labels.respond_to?(:call)
          template.instance_exec(value, &labels)
        elsif labels.is_a?(Hash)
          labels[value] || labels[value.to_s]
        else
          labels
        end
        resolved.to_s.presence || value.to_s
      end

      def autocomplete_locals(object_name:, field_name:, current_value:)
        {
          object_name: object_name,
          field_name: field_name,
          search_url: autocomplete_search_url,
          placeholder: autocomplete_placeholder,
          initial_value: current_value,
          initial_label: initial_label_for(current_value),
          selected_items: selected_items_for(current_value),
          label_text: label_from_options,
          controller_name: CONTROLLER,
          value_field: value_field?,
          multiple: multiple?,
          page_size: page_size_value,
          params: static_params,
          param_fields: param_fields
        }
      end
    end
  end
end
