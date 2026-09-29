require 'json'

module OSF
  module Downloader
    # Parses an OSF file record (https://api.osf.io/v2/files/<id>)
    class FileParser
      PreprintFile = Data.define :name, :size, :sha256, :url

      def initialize json
        @file = JSON.parse(json).fetch 'data'
      end

      def file
        attributes = @file.fetch 'attributes', {}

        PreprintFile.new(
          name:   attributes.fetch('name'),
          size:   attributes['size'],
          sha256: attributes.dig('extra', 'hashes', 'sha256'),
          url:    @file.dig('links', 'download')
        )
      end
    end
  end
end
