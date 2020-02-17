class LearnToRank::Features::Timestamp
  include LearnToRank::Features::Normalisable

  # These are approximate; it's OK if a date is above/below them.
  MAX_TIMESTAMP = Time.now.to_f
  MIN_TIMESTAMP = Time.new(2012, 1, 1).to_f

  def initialize(timestamp_str)
    @value = parse(timestamp_str)
  end

  def normalised
    return 0.0 unless value

    normalise_minmax(value, MIN_TIMESTAMP, MAX_TIMESTAMP)
  end

private

  attr_reader :value

  def parse(timestamp_str)
    return if timestamp_str.nil? || timestamp_str.empty? || !timestamp_str.is_a?(String)

    Date.parse(timestamp_str).to_time.to_f
  end
end
