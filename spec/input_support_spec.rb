# frozen_string_literal: true

require "activeadmin/autocompletes/filter_autocomplete"
require "activeadmin/autocompletes/input_support"

RSpec.describe ActiveAdmin::Autocompletes::InputSupport do
  let(:host) do
    Class.new do
      include ActiveAdmin::Autocompletes::InputSupport

      attr_accessor :options, :template

      def label_from_options
        "Label"
      end

      def public_static_params = static_params
      def public_param_fields = param_fields
      def public_page_size = page_size_value
    end.new
  end

  before do
    host.options = {}
    host.template = Object.new
  end

  it "normalizes static params from a hash or callable" do
    host.options = {params: {category_id: 7, blank: nil}}
    expect(host.public_static_params).to eq("category_id" => "7", "blank" => nil)

    host.template.define_singleton_method(:instance_exec) { |&block| block.call }
    host.options = {params: -> { {scope: "active"} }}
    expect(host.public_static_params).to eq("scope" => "active")
  end

  it "stringifies param_fields selectors" do
    host.options = {param_fields: {category_id: "#q_category_id_eq"}}
    expect(host.public_param_fields).to eq("category_id" => "#q_category_id_eq")
  end

  it "clamps page_size through FilterAutocomplete bounds" do
    host.options = {page_size: 10_000}
    expect(host.public_page_size).to eq(ActiveAdmin::Autocompletes::FilterAutocomplete::MAX_LIMIT)

    host.options = {}
    expect(host.public_page_size).to be_nil
  end
end
