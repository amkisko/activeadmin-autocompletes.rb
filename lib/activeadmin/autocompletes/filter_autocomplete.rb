# frozen_string_literal: true

module ActiveAdmin
  module Autocompletes
    module FilterAutocomplete
      DEFAULT_LIMIT = 20
      MAX_LIMIT = 50
      MAX_QUERY_CHARS = 200

      def self.clamp_limit(raw)
        raw.to_i.clamp(1, MAX_LIMIT)
      end

      def self.clamp_query(raw)
        query = raw.to_s.strip
        query = query.byteslice(0, MAX_QUERY_CHARS).to_s
        query.empty? ? nil : query
      end

      def filter_autocomplete(attribute, action: nil, &block)
        raise ArgumentError, "filter_autocomplete requires a block" unless block

        action_name = (action || :"#{attribute}_options").to_sym

        collection_action action_name, method: :get do
          authorize! :index, config.resource_class

          limit = ActiveAdmin::Autocompletes::FilterAutocomplete.clamp_limit(
            params.fetch(:limit, ActiveAdmin::Autocompletes::FilterAutocomplete::DEFAULT_LIMIT)
          )
          offset = [params.fetch(:offset, 0).to_i, 0].max
          query = ActiveAdmin::Autocompletes::FilterAutocomplete.clamp_query(params[:q])

          items = instance_exec(query:, limit:, offset:, &block)
          render json: Array(items)
        end
      end
    end
  end
end
