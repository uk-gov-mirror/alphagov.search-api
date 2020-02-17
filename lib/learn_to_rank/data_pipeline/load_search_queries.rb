require "csv"

module LearnToRank::DataPipeline
  module LoadSearchQueries
    def self.from_csv(datafile)
      queries = {}
      CSV.foreach(datafile, headers: true) do |row|
        # Todo change the column names in the query
        query = row["searchTerm"].strip
        group_by = row["contentId"].present? && row["contentId"] != "(not set)" ? "content_id" : "links"
        key = "#{query}-#{group_by}"
        queries[key] ||= []
        queries[key] << {
          query: query,
          link: row["link"] == "(not set)" ? nil : row["link"],
          content_id: row["contentId"] == "(not set)" ? nil : row["contentId"],
          rank: row["avg_rank"],
          views: row["views"],
          clicks: row["clicks"],
        }
      end
      queries
    end

    def self.from_bigquery(rows)
      queries = {}
      rows.each do |row|
        query = row[:searchTerm].strip
        group_by = row[:contentId].present? && row[:contentId] != "(not set)" ? "content_id" : "links"
        key = "#{query}-#{group_by}"
        queries[key] ||= []
        queries[key] << {
          query: query,
          link: row[:link] == "(not set)" ? nil : row[:link],
          content_id: row[:contentId] == "(not set)" ? nil : row[:contentId],
          rank: row[:avg_rank],
          views: row[:views],
          clicks: row[:clicks],
        }
      end
      queries
    end
  end
end
