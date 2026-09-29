module OSF
  module Downloader
    # Synthesized from the preprint metadata
    class Bibtex
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        <<~BIBTEX
          @misc{#{key},
            title={#{@metadata.title}},
            author={#{authors}},
            year={#{year}},
            publisher={#{@metadata.provider}},
            doi={#{@metadata.preprint_doi}},
            url={#{@metadata.osf_url}},
          }
        BIBTEX
      end

      def key
        title_word = DL::Core::Slug.new(@metadata.title).to_s.split('-').first

        "#{surname}#{year}#{title_word}"
      end

      private

      def authors
        @metadata.authors.map(&:name).join ' and '
      end

      # authors are "Family, Given"
      def surname
        first_author = @metadata.authors.first
        return 'anonymous' if first_author.nil?

        first_author.name.split(',').first.downcase.gsub(/[^a-z]/, '')
      end

      def year
        @metadata.published.to_s[0, 4]
      end
    end
  end
end
