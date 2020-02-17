class LearnToRank::Features::LinkSlashCount
  include LearnToRank::Features::Normalisable

  def initialize(link)
    @value = link
  end

  def normalised
    return 0.0 if value.nil? || value.empty?

    val = value.count("/").to_f
    normalise_minmax(val, 0, MAX_LINK_SLASH_COUNT)
  end

private

  attr_reader :value, :max_length

  MAX_LINK_SLASH_COUNT = 50
end
