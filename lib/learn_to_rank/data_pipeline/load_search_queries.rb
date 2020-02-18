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

    # job here is a query_job (Data class):
    # https://googleapis.dev/ruby/google-cloud-bigquery/latest/Google/Cloud/Bigquery/Data.html
    def self.from_bigquery(data)
      data.all.lazy.each_with_object({}) do |row, queries|
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
    end
  end
end
