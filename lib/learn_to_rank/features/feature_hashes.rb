# Implements https://en.wikipedia.org/wiki/Feature_hashing
class LearnToRank::Features::FeatureHashes
  include LearnToRank::Features::Normalisable

  def initialize(str_array)
    @value = parse(str_array)
  end

  def normalised
    return 0.0 unless value

    normalise_str(value)
  end

private

  attr_reader :value

  def parse(str_array)
    return if str_array.nil? || str_array.empty?

    str_array.sort.join
  end
end
