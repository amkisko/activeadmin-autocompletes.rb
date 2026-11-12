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

      def public_selected_items(value) = selected_items_for(value)

      def public_initial_label(value) = initial_label_for(value)

      def public_label_for(value, labels) = label_for_value(value, labels)

      def public_search_url = autocomplete_search_url

      def public_placeholder = autocomplete_placeholder

      def public_locals(value) = autocomplete_locals(
        object_name: "q",
        field_name: "name_eq",
        current_value: value
      )
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

  it "builds selected chip items for multiple values and skips blanks" do
    host.template.define_singleton_method(:instance_exec) { |value, &block| block.call(value) }
    host.options = {
      multiple: true,
      initial_labels: ->(value) { "Label #{value}" }
    }

    expect(host.public_selected_items(["a", "", nil, "b"])).to eq(
      [
        {value: "a", label: "Label a"},
        {value: "b", label: "Label b"}
      ]
    )
  end

  it "resolves labels from callables, hashes, and fallbacks" do
    host.template.define_singleton_method(:instance_exec) { |value, &block| block.call(value) }

    expect(host.public_label_for("7", ->(value) { "Thing #{value}" })).to eq("Thing 7")
    expect(host.public_label_for(7, {7 => "By id", "7" => "By string"})).to eq("By id")
    expect(host.public_label_for("7", {"7" => "By string"})).to eq("By string")
    expect(host.public_label_for("7", nil)).to eq("7")
    expect(host.public_initial_label(nil)).to eq("")
    expect(host.public_initial_label("kept")).to eq("kept")
  end

  it "exposes search url, placeholder, and autocomplete locals" do
    host.template.define_singleton_method(:instance_exec) { |&block| block.call }
    host.options = {
      url: -> { "/admin/things/search_options" },
      placeholder: "Find things",
      value_field: true,
      multiple: true,
      page_size: 5,
      params: {scope: "active"},
      param_fields: {category_id: "#q_category_id_eq"},
      initial_labels: {"1" => "One"}
    }

    expect(host.public_search_url).to eq("/admin/things/search_options")
    expect(host.public_placeholder).to eq("Find things")

    locals = host.public_locals(["1", ""])
    expect(locals).to include(
      object_name: "q",
      field_name: "name_eq",
      search_url: "/admin/things/search_options",
      placeholder: "Find things",
      value_field: true,
      multiple: true,
      page_size: 5,
      params: {"scope" => "active"},
      param_fields: {"category_id" => "#q_category_id_eq"},
      selected_items: [{value: "1", label: "One"}]
    )
  end
end
