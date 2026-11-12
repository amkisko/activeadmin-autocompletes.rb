# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveAdmin::Autocompletes::FilterAutocomplete do
  it "registers a GET collection_action that clamps query and limit" do
    resource = Class.new do
      extend ActiveAdmin::Autocompletes::FilterAutocomplete

      class << self
        attr_reader :registered

        def collection_action(name, **options, &block)
          @registered = {name: name, options: options, block: block}
        end
      end
    end

    resource.filter_autocomplete :search do |query:, limit:, offset:|
      [{label: query.to_s, value: "#{limit}:#{offset}"}]
    end

    expect(resource.registered[:name]).to eq(:search_options)
    expect(resource.registered[:options]).to eq(method: :get)

    controller = Object.new
    controller.define_singleton_method(:authorize!) { |*| true }
    controller.define_singleton_method(:config) { Struct.new(:resource_class).new(Object) }
    controller.define_singleton_method(:params) do
      {
        limit: "999",
        offset: "-3",
        q: "  #{"x" * 250}  "
      }
    end
    rendered = nil
    controller.define_singleton_method(:render) { |json:| rendered = json }

    controller.instance_exec(&resource.registered[:block])

    expect(rendered.size).to eq(1)
    expect(rendered.first[:value]).to eq("50:0")
    expect(rendered.first[:label].bytesize).to eq(described_class::MAX_QUERY_CHARS)
  end
end
