require 'engtagger'

class LearnToRank::Features::QueryIntent
  def initialize(query)
    @query = query
  end

  def verb_count
    return 0.0 if invalid_query

    tagged = tagger.add_tags(query)
    Float(tagger.get_verbs(tagged).keys.count)
  end

  def noun_count
    return 0.0 if invalid_query

    tagged = tagger.add_tags(query)
    Float(tagger.get_nouns(tagged).keys.count)
  end

  def adjectives_count
    return 0.0 if invalid_query

    tagged = tagger.add_tags(query)
    Float(tagger.get_adjectives(tagged).keys.count)
  end

  def contains_numbers
    return 0.0 if invalid_query

    !query[/\d/].nil? ? 1 : 0
  end

  def word_count
    return 0.0 if invalid_query

    Float(query.split.size)
  end

private

  def invalid_query
    query.nil? || query.empty?
  end

  def tagger
    @tagger = EngTagger.new
  end

  attr_reader :query
end
