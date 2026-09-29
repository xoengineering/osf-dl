module OSF
  module Downloader
    # The body of metadata.md
    class MarkdownBody
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        <<~MARKDOWN

          # #{@metadata.title}

          #{authors_list}

          - Published: #{@metadata.published}
          - Server: #{@metadata.provider}
          - Version: #{@metadata.version}
          - OSF: [#{@metadata.preprint_doi}](#{@metadata.osf_url})
          - License: #{@metadata.license}

          ## Abstract

          #{@metadata.abstract}
        MARKDOWN
      end

      private

      def authors_list
        @metadata.authors.map { |author| "- #{author.name}" }.join "\n"
      end
    end
  end
end
