# TODO: These features could be computed at index-time, to speed up queries.
class LearnToRank::Features::StringLength
  include LearnToRank::Features::Normalisable

  def initialize(string, max_length:)
    @value, @max_length = string, max_length
  end

  def normalised
    return 0.0 if value.nil? || value.empty?

    normalise_minmax(value.length.to_f, 0, max_length)
  end

private

  attr_reader :value, :max_length
end
