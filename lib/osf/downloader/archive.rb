require 'digest'
require 'fileutils'

module OSF
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      # Downloads into <destination>.partial/ and
      # renames it into place only once the file matched its checksum.
      # An archived version is always complete and is skipped.
      # PaperFolder decides flat (single version) vs v<N>/ (several versions).
      def run
        raise NotAvailable unless parser.available?
        return paper_folder.location_of(metadata.version) if paper_folder.archived? metadata.version

        paper_folder.unflatten!
        FileUtils.rm_rf staging_dir
        FileUtils.mkdir_p staging_dir

        download_primary_file
        write_preprint
        write_sidecars

        File.rename staging_dir, destination
        destination
      end

      private

      # an unversioned ID resolves to the latest version
      def preprint
        @preprint ||= get "https://api.osf.io/v2/preprints/#{@identifier}/"
      rescue DL::Core::HTTPError => e
        raise PaperNotFound if e.status == 404

        raise
      end

      def related
        @related ||= PreprintParser.related_urls preprint
      end

      def parser
        @parser ||= PreprintParser.new preprint:, citation: get(related[:citation]), license: license
      end

      def license
        related[:license] && get(related[:license])
      end

      def metadata
        @metadata ||= parser.metadata
      end

      def get url
        @client.get(url).to_s
      end

      def paper_folder
        @paper_folder ||= DL::Core::PaperFolder.new File.join(@root, Path.new(metadata).to_s)
      end

      # evaluated after unflatten!, which can turn a flat folder into v<N>/ folders
      def destination
        @destination ||= paper_folder.destination_for metadata.version
      end

      # a sibling of destination, so the rename is a single atomic step
      def staging_dir
        "#{destination}.partial"
      end

      # File.basename keeps a name from the record from pointing outside the folder
      def download_primary_file
        file = FileParser.new(get(related[:primary_file])).file
        body = get file.url
        verify file, body

        File.binwrite File.join(staging_dir, File.basename(file.name)), body
      end

      def verify file, body
        actual = Digest::SHA256.hexdigest body
        return if actual == file.sha256

        raise ChecksumMismatch, "#{file.name}: expected SHA-256 #{file.sha256}, got #{actual}"
      end

      # OSF's own preprint record, verbatim
      def write_preprint
        File.write File.join(staging_dir, 'osf.json'), preprint
      end

      def write_sidecars
        body = MarkdownBody.new(metadata).to_s
        key  = Bibtex.new(metadata).key

        DL::Core::Sidecar::Markdown.new(metadata, body:, extras: { bibtex_key: key }).write to: staging_dir
        DL::Core::Sidecar::YAML.new(metadata).write to: staging_dir
        DL::Core::Sidecar::JSON.new(metadata).write to: staging_dir
        File.write File.join(staging_dir, 'metadata.bib'), Bibtex.new(metadata).to_s
      end
    end
  end
end
