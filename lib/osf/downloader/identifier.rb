require 'uri'

module OSF
  module Downloader
    # An OSF preprint ID (a five-character GUID like cjy8e), with its version
    # when one was given (cjy8e_v1).
    class Identifier
      class Invalid < Error; end

      ID  = /\A(?<id>[a-z0-9]{5})(?:_v(?<version>\d+))?\z/
      DOI = %r{\A(?:doi:)?10\.\d+/osf\.io/(?<id>[a-z0-9]{5})(?:_v(?<version>\d+))?\z}

      attr_reader :id, :version, :input

      def initialize input
        @input = input
        match  = parse input.to_s.strip
        raise Invalid, "not an OSF preprint identifier: #{input}" if match.nil?

        @id      = match[:id]
        @version = match[:version] && Integer(match[:version])
      end

      def to_s = version.nil? ? id : "#{id}_v#{version}"

      private

      def parse text
        ID.match(text) || DOI.match(text) || parse_url(text)
      end

      # osf.io/<id>, osf.io/preprints/<provider>/<id>, api.osf.io/v2/preprints/<id>, and doi.org
      def parse_url text
        uri = URI.parse(text.include?('://') ? text : "https://#{text}")

        case uri.host
        when 'osf.io', 'www.osf.io', 'api.osf.io' then ID.match uri.path.to_s.split('/').reject(&:empty?).last.to_s
        when 'doi.org', 'dx.doi.org' then DOI.match uri.path.to_s.delete_prefix('/')
        end
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
