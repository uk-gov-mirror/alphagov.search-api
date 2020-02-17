require "learn_to_rank/explain_scores"
require "learn_to_rank/organisation_enums"
require "learn_to_rank/format_enums"

module LearnToRank
  class Features
    include OrganisationEnums
    include FormatEnums
    # Features takes some values and translates them to features

    # These are approximate expected values. It is OK for values to exceed
    # these. These are magic numbers though, and are likely to become stale.
    MAX_TITLE_LENGTH = 100
    MAX_DESCRIPTION_LENGTH = 1_000
    MAX_LINK_LENGTH = 100
    MAX_QUERY_LENGTH = 100
    MAX_INDEXABLE_CONTENT_LENGTH = 500_000

    def call(
      explain: {}, popularity: 0, es_score: 0, title: "",
      description: "", link: "", public_timestamp: "", format: nil,
      organisation_content_ids: [], indexable_content: "",
      query: "", updated_at: "")

      explain_scores = LearnToRank::ExplainScores.new(explain)
      query_intent   = Features::QueryIntent.new(query)

      {
        "1" => parse_float(popularity),
        "2" => parse_float(es_score),
        "3" => explain_scores.title_score,
        "4" => explain_scores.description_score,
        "5" => explain_scores.indexable_content_score,
        "6" => explain_scores.all_searchable_text_score,
        "7" => Features::StringLength.new(title, max_length: MAX_TITLE_LENGTH).normalised,
        "8" => Features::StringLength.new(description, max_length: MAX_DESCRIPTION_LENGTH).normalised,
        "9" => Features::StringLength.new(link, max_length: MAX_LINK_LENGTH).normalised,
        "10" => Features::Timestamp.new(public_timestamp).normalised,
        "11" => Float(format ? format_enums[format] || 0 : 0),
        # Features::FeatureHash.new(format).normalised,
        # Features::FeatureHashes.new(organisation_content_ids).normalised,
        "12" => Float(organisation_content_ids && organisation_content_ids.any? ? organisation_enums[organisation_content_ids.first] || 0 : 0),
        "13" => Features::StringLength.new(query, max_length: MAX_QUERY_LENGTH).normalised,
        "14" => Features::StringLength.new(indexable_content, max_length: MAX_INDEXABLE_CONTENT_LENGTH).normalised,
        "15" => Features::LinkSlashCount.new(link).normalised,
        "16" => Features::Timestamp.new(updated_at).normalised,
        "17" => Features::Levenstein.new(query, indexable_content).distance,
        "18" => Features::Levenstein.new(query, title).distance,
        "19" => Features::Levenstein.new(query, description).distance,
        "20" => query_intent.word_count,
        "21" => query_intent.contains_numbers,
        # "22" => timed { puts"timing noun_count"; query_intent.noun_count },
        # "23" => timed { puts"timing adjectives_count"; query_intent.adjectives_count },
        # "24" => timed { puts"timing verb_count"; query_intent.verb_count },
      }
    end

  private

    def parse_float(num)
      return 0.0 unless num

      Float(num)
    end

    def timed(&block)
      start = Time.now
      x = yield
      time= ("%.20f" % "#{(Time.now - start).to_f}").sub(/\.?0*$/, "")
      puts "Took #{time} seconds"
      x
    end
  end
end
