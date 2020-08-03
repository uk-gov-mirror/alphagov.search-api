module Indexer
  # assumes it's run after AttachmentsLookup
  class PartsLookup
    def initialize
      @logger = Logging.logger[self]
    end

    def self.prepare_parts(doc_hash)
      new.prepare_parts(doc_hash)
    end

    def prepare_parts(doc_hash)
      return doc_hash unless doc_hash["parts"].nil?

      attachments = doc_hash.fetch("attachments", []).select { |a| can_be_a_part?(doc_hash, a) }
      return doc_hash if attachments.empty?

      doc_hash.merge("parts" => attachments.map { |a| fetch_attachment_part(a) })
    end

  private

    def find_content_id(doc_hash)
      Indexer::find_content_id(doc_hash, @logger)
    end

    def fetch_attachment_part(attachment)
      part = fetch_from_publishing_api(attachment["url"])

      {
        "slug" => attachment["url"].split("/").last,
        "title" => attachment["title"],
        "body" => summarise(part.dig("details", "body")),
      }
    end

    def can_be_a_part?(doc_hash, attachment)
      return false unless attachment["url"]
      return false unless attachment["content"]

      # we don't index full part URLs, only slugs, so we need to
      # ensure the full prefix matches
      return false unless attachment["url"].start_with? doc_hash["link"]

      true
    end
  end
end
