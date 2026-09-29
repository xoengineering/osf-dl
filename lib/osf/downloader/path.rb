module OSF
  module Downloader
    # The preprint's folder, shared by all its versions
    class Path
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        [date_dir, @metadata.provider, "#{@metadata.osf_id}-#{slug}"].join '/'
      end

      private

      # 2026-09-29 becomes 2026/09/29
      def date_dir
        @metadata.published.to_s.split('-').join '/'
      end

      def slug
        DL::Core::Slug.new(@metadata.title).to_s
      end
    end
  end
end
