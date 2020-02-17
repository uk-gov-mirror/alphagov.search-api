# Implements https://en.wikipedia.org/wiki/Feature_hashing
class LearnToRank::Features::FeatureHash
  include LearnToRank::Features::Normalisable

  def initialize(str)
    @value = str
  end

  def normalised
    return 0.0 unless value && value.is_a?(String)

    normalise_str(value)
  end

private

  attr_reader :value
end
