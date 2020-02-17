require 'levenshtein'

class LearnToRank::Features::Levenstein
  def initialize(text_a, text_b)
    @text_a, @text_b = text_a, text_b
  end

  def distance
    return 0.0 if text_a.nil? || text_a.empty? || text_b.nil? || text_b.empty?

    distance = Levenshtein.distance(text_a, text_b)
    max_distance = [text_a.length, text_b.length].max.to_f
    min = 0.0
    max = 1.0
    ((distance - min) / (max_distance - min) * (max - min) + min)
  end

private

  attr_reader :text_a, :text_b
end
