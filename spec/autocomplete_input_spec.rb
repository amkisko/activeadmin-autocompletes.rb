# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Inputs::AutocompleteInput do
  def build_input(object:, method: :name, options: {})
    input = described_class.allocate
    input.define_singleton_method(:options) { options }
    input.define_singleton_method(:object) { object }
    input.define_singleton_method(:method) { method }
    input
  end

  it "prefers an explicit selected option" do
    expect(build_input(object: nil, options: {selected: "preset"}).send(:current_value)).to eq("preset")
  end

  it "reads the attribute from the object when present" do
    object = Struct.new(:name).new("Helsinki")
    expect(build_input(object: object).send(:current_value)).to eq("Helsinki")
  end

  it "returns nil when the attribute raises NoMethodError" do
    object = Object.new
    object.define_singleton_method(:name) { raise NoMethodError }

    expect(build_input(object: object).send(:current_value)).to be_nil
  end
end

RSpec.describe ActiveAdmin::Inputs::Filters::AutocompleteInput do
  def build_input(object:, method: :name_eq)
    input = described_class.allocate
    input.instance_variable_set(:@object, object)
    input.define_singleton_method(:method) { method }
    input
  end

  it "returns nil when the filter value raises NoMethodError" do
    object = Object.new
    object.define_singleton_method(:name_eq) { raise NoMethodError }

    expect(build_input(object: object).send(:current_value)).to be_nil
  end
end
