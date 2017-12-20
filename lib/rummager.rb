$LOAD_PATH << __dir__ unless $LOAD_PATH.include?(__dir__)

require_relative '../env'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string'
require 'cgi'
require 'csv'
require 'elasticsearch'
require 'erb'
require 'fileutils'
require 'gds_api/publishing_api_v2'
require 'sentry-raven'
require 'govuk_app_config'
require 'json'
require 'logging'
require 'loofah'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'plek'
require 'redis'
require 'securerandom'
require 'sidekiq'
require 'sidekiq-limit_fetch'
require 'statsd'
require 'time'
require 'unf'
require 'uri'
require 'yaml'

initializers_path = File.expand_path("../config/initializers/*.rb", __dir__)
Dir[initializers_path].each { |f| require f }

require 'analytics_data'
require File.expand_path('../config/logging_setup', __dir__)
require 'document'
require 'duplicate_deleter'
require 'duplicate_links_finder'
require 'govuk_document_types'
require 'special_route_publisher'

require 'indexer'
require 'indexer/amender'
require 'indexer/bulk_payload_generator'
require 'indexer/change_notification_processor'
require 'indexer/compare_enumerator'
require 'indexer/comparer'
require 'indexer/document_preparer'
require 'indexer/exceptions'
require 'indexer/links_lookup'
require 'indexer/message_processor'
require 'indexer/govuk_index_field_comparer'
require 'indexer/popularity_lookup'
require 'indexer/workers/base_worker'
require 'indexer/workers/amend_worker'
require 'indexer/workers/bulk_index_worker'
require 'indexer/workers/delete_worker'

require 'govuk_index/updater'
require 'govuk_index/client'
require 'govuk_index/document_type_inferer'
require 'govuk_index/elasticsearch_processor'
require 'govuk_index/page_traffic_worker'
require 'govuk_index/method_builder'
require 'govuk_index/indexable_content_sanitiser'
require 'govuk_index/migrated_formats'
require 'govuk_index/page_traffic_loader'
require 'govuk_index/popularity_updater'
require 'govuk_index/popularity_worker'
require 'govuk_index/presenters/common_fields_presenter'
require 'govuk_index/presenters/details_presenter'
require 'govuk_index/presenters/elasticsearch_presenter'
require 'govuk_index/presenters/expanded_links_presenter'
require 'govuk_index/presenters/indexable_content_presenter'
require 'govuk_index/presenters/specialist_presenter'
require 'govuk_index/publishing_event_processor'
require 'govuk_index/publishing_event_worker'
require 'govuk_index/sync_updater'
require 'govuk_index/sync_worker'
require 'govuk_message_queue_consumer'

require 'metasearch_index/client'
require 'metasearch_index/deleter'
require 'metasearch_index/inserter'
require 'search/aggregate_example_fetcher'
require 'search/aggregate_option'
require 'search/best_bets_checker'
require 'search/escaping'
require 'search/format_migrator'
require 'search/matcher_set'
require 'search/presenters/aggregate_result_presenter'
require 'search/presenters/entity_expander'
require 'search/presenters/field_presenter'
require 'search/presenters/highlighted_description'
require 'search/presenters/highlighted_field'
require 'search/presenters/highlighted_title'
require 'search/presenters/result_presenter'
require 'search/presenters/result_set_presenter'
require 'search/presenters/spell_check_presenter'
require 'search/query'
require 'search/query_helpers'
require 'search/query_builder'
require 'search/query_components/base_component'
require 'search/query_components/aggregates'
require 'search/query_components/best_bets'
require 'search/query_components/booster'
require 'search/query_components/core_query'
require 'search/query_components/filter'
require 'search/query_components/highlight'
require 'search/query_components/popularity'
require 'search/query_components/sort'
require 'search/query_components/suggest'
require 'search/query_components/user_filter'
require 'search/query_components/visibility_filter'
require 'search/query_parameters'
require 'search/registries'
require 'search/registry'
require 'search/result_set'
require 'search/suggestion_blacklist'
require 'search/timed_cache'

require 'index'
require 'index_finder'
require 'index_group'
require 'legacy_client/index_for_search'
require 'legacy_client/multivalue_converter'
require 'legacy_client/multivalue_converter'
require 'legacy_search/advanced_search'
require 'legacy_search/advanced_search_query_builder'
require 'schema_migrator'
require 'missing_metadata/fetcher'
require 'missing_metadata/runner'
require 'parameter_parser/base_parameter_parser'
require 'parameter_parser/aggregate_parameter_parser'
require 'parameter_parser/aggregates_parameter_parser'
require 'parameter_parser/search_parameter_parser'
require 'rummager/config'
require 'rummager/helpers'
require 'schema/combined_index_schema'
require 'schema/elasticsearch_type'
require 'schema/field_definitions'
require 'schema/field_types'
require 'schema/index_schema'
require 'schema/schema_config'
require 'schema/synonyms'
require 'scroll_enumerator'

require 'search_config'
require 'search_server'
require 'services'
require 'sitemap/property_boost_calculator'
require 'sitemap/sitemap'
require 'sitemap/sitemap_cleanup'
require 'sitemap/sitemap_generator'
require 'sitemap/sitemap_presenter'
require 'sitemap/sitemap_writer'
