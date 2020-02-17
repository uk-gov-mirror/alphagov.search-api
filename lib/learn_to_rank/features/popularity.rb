class LearnToRank::Features::Popularity
  def initialize(popularity)
    @value = popularity || 0.0
  end

  def normalised
    value
  end

private

  attr_reader :value
end
