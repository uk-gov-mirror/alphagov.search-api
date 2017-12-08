require 'spec_helper'

RSpec.describe Search::HighlightedDescription do
  it "adds highlighting if present" do
    raw_result = {
      "fields" => { "description" => "I will be highlighted." },
      "highlight" => { "description" => ["I will be <mark>highlighted</mark>."] }
    }

    highlighted_description = described_class.new(raw_result).text

    expect(highlighted_description).to eq("I will be <mark>highlighted</mark>.")
  end

  it "uses default description if highlight not found" do
    raw_result = {
      "fields" => { "description" => "I will not be highlighted & escaped." }
    }

    highlighted_description = described_class.new(raw_result).text

    expect(highlighted_description).to eq("I will not be highlighted &amp; escaped.")
  end

  it "truncates default description if highlight not found" do
    raw_result = {
      "fields" => { "description" => ("This is a sentence that is too long." * 10) }
    }

    highlighted_description = described_class.new(raw_result).text

    expect(highlighted_description.size).to eq(225)
    expect(highlighted_description.ends_with?('…')).to be_truthy
  end

  it "returns empty string if theres no description" do
    raw_result = {
      "fields" => { "description" => nil }
    }

    highlighted_description = described_class.new(raw_result).text

    expect(highlighted_description).to eq("")
  end
end
