require 'json'

module OSF
  module Downloader
    # Parses an OSF preprint (https://api.osf.io/v2/preprints/<id>), with its
    # citation (for author names) and its license (for the license name).
    class PreprintParser
      DOI_URL = 'https://doi.org/'.freeze

      # the URLs of the records a preprint links to, fetched before parsing
      def self.related_urls preprint_json
        relationships = JSON.parse(preprint_json).dig 'data', 'relationships'

        {
          primary_file: relationships.dig('primary_file', 'links', 'related', 'href'),
          citation:     relationships.dig('citation', 'links', 'related', 'href'),
          license:      relationships.dig('license', 'links', 'related', 'href')
        }
      end

      def initialize preprint:, citation:, license:
        @preprint = JSON.parse(preprint).fetch 'data'
        @citation = JSON.parse(citation).dig 'data', 'attributes'
        @license  = license && JSON.parse(license).dig('data', 'attributes', 'name')
      end

      def metadata
        Metadata.new(
          osf_id:       Identifier.new(@preprint.fetch('id')).id,
          version:      attributes['version'],
          provider:     @preprint.dig('relationships', 'provider', 'data', 'id'),
          osf_url:      @preprint.dig('links', 'html'),
          preprint_doi: @preprint.dig('links', 'preprint_doi').to_s.delete_prefix(DOI_URL),
          doi:          attributes['doi'],
          title:        attributes['title'],
          authors:      authors,
          abstract:     attributes['description'],
          published:    attributes['date_published'].to_s[0, 10],
          subjects:     Array(attributes['subjects']).flatten.map { it['text'] }.uniq,
          tags:         Array(attributes['tags']),
          license:      @license
        )
      end

      # withdrawn and unpublished preprints have nothing to archive
      def available?
        attributes['is_published'] == true && attributes['date_withdrawn'].nil?
      end

      private

      def attributes
        @preprint.fetch 'attributes', {}
      end

      def authors
        Array(@citation&.fetch('author', nil)).map do |author|
          DL::Core::Author.new name: [author['family'], author['given']].compact.join(', ')
        end
      end
    end
  end
end
