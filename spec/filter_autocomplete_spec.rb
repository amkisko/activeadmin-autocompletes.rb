# frozen_string_literal: true

require "activeadmin/autocompletes/filter_autocomplete"

RSpec.describe ActiveAdmin::Autocompletes::FilterAutocomplete do
  it "exposes bounded default and max option page sizes" do
    expect(described_class::DEFAULT_LIMIT).to eq(20)
    expect(described_class::MAX_LIMIT).to eq(50)
    expect(described_class::MAX_QUERY_CHARS).to eq(200)
  end

  describe ".clamp_limit" do
    it "clamps oversized limits to MAX_LIMIT" do
      expect(described_class.clamp_limit(10_000)).to eq(described_class::MAX_LIMIT)
    end

    it "clamps non-positive limits to 1" do
      expect(described_class.clamp_limit(0)).to eq(1)
      expect(described_class.clamp_limit(-5)).to eq(1)
    end

    it "keeps in-range limits" do
      expect(described_class.clamp_limit(described_class::DEFAULT_LIMIT)).to eq(described_class::DEFAULT_LIMIT)
    end
  end

  describe ".clamp_query" do
    it "returns nil for blank input" do
      expect(described_class.clamp_query("   ")).to be_nil
      expect(described_class.clamp_query(nil)).to be_nil
    end

    it "strips whitespace" do
      expect(described_class.clamp_query("  helsinki  ")).to eq("helsinki")
    end

    it "truncates to MAX_QUERY_CHARS bytes" do
      long = "a" * (described_class::MAX_QUERY_CHARS + 50)
      clamped = described_class.clamp_query(long)
      expect(clamped.bytesize).to eq(described_class::MAX_QUERY_CHARS)
    end
  end
end
