require "analytics_data"
require "integration_test_helper"
require "json"

class AnalyticsDataTest < IntegrationTest
  def setup
    @analytics_data_fetcher = AnalyticsData.new(stubbed_search_config.elasticsearch["base_uri"], ["mainstream_test"])
  end

  def test_fetches_rows_of_analytics_dimensions
    document = {
      "content_id" => "587b0635-2911-49e6-af68-3f0ea1b07cc5",
      "link" => "/an-example-page",
      "title" => "some page title",
      "content_store_document_type" => "some_document_type",
      "primary_publishing_organisation" => %w(some_publishing_org),
      "organisations" => %w(some_org another_org yet_another_org),
      "navigation_document_supertype" => "some_navigation_supertype",
      "user_journey_document_supertype" => "some_user_journey_supertype",
      "public_timestamp" => "2017-06-20T10:21:55.000+01:00",
    }
    commit_document("mainstream_test", document)

    rows = @analytics_data_fetcher.rows

    expected_row = [
        "587b0635-2911-49e6-af68-3f0ea1b07cc5",
        "/an-example-page",
        "some_publishing_org",
        nil,
        "some page title",
        "some_document_type",
        "some_navigation_supertype",
        nil,
        "some_user_journey_supertype",
        "some_org, another_org, yet_another_org",
        "20170620",
        nil,
        nil,
      ]

    assert_equal [expected_row], rows.to_a
  end

  def test_missing_data_is_nil
    document = {}
    commit_document("mainstream_test", document)

    rows = @analytics_data_fetcher.rows

    expected_row = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]

    assert_equal [expected_row], rows.to_a
  end

  def test_fetches_all_rows
    fixture_file = File.expand_path("../fixtures/content_for_analytics.json", __FILE__)
    documents = JSON.parse(File.read(fixture_file))
    documents.each do |document|
      commit_document("mainstream_test", document)
    end

    analytics_data = @analytics_data_fetcher.rows.to_a

    assert_equal 30, analytics_data.size
  end

  def test_headers_and_rows_are_consisent
    document = {
      "content_id" => "587b0635-2911-49e6-af68-3f0ea1b07cc5",
      "link" => "/an-example-page",
      "popularity": 0.5,
    }
    commit_document("mainstream_test", document)

    rows = @analytics_data_fetcher.rows
    headers = @analytics_data_fetcher.headers

    assert_equal headers.size, rows.first.size
  end
end
