require 'digest'
require 'json'
require 'tmpdir'

RSpec.describe OSF::Downloader::Archive do
  let(:fixtures)   { 'spec/fixtures/http' }
  let(:client)     { OSF::Downloader::Client.new(rate_limit: 0) }
  let(:identifier) { OSF::Downloader::Identifier.new 'cjy8e_v1' }
  let(:paper_dir) do
    '2026/09/29/psyarxiv/cjy8e-exploratory-item-response-matrix-factorization-bridging-psychometrics-and'
  end

  let(:preprint_url) { 'https://api.osf.io/v2/preprints/cjy8e_v1/' }
  let(:file_url)     { 'https://api.osf.io/v2/files/6abb891cf1ccf5076851ef9b/' }
  let(:download_url) { 'https://osf.io/download/6abb891cf1ccf5076851ef9b/' }
  let(:preprint)     { File.read "#{fixtures}/preprint-cjy8e_v1.json" }
  let(:pdf)          { File.binread "#{fixtures}/pdf-cjy8e_v1.pdf" }

  # The recorded PDF is the first 4 KB of the real file, so the file record's
  # SHA-256 is set to that of the 4 KB.
  let(:file_record) do
    record = JSON.parse File.read("#{fixtures}/file-6abb891cf1ccf5076851ef9b.json")
    record['data']['attributes']['extra']['hashes']['sha256'] = Digest::SHA256.hexdigest(pdf)
    JSON.generate record
  end

  before do
    stub_request(:get, preprint_url).to_return(status: 200, body: preprint)
    stub_request(:get, 'https://api.osf.io/v2/preprints/cjy8e_v1/citation/')
      .to_return(status: 200, body: File.read("#{fixtures}/citation-cjy8e_v1.json"))
    stub_request(:get, 'https://api.osf.io/v2/licenses/563c1cf88c5e4a3877f9e96a/')
      .to_return(status: 200, body: File.read("#{fixtures}/license-563c1cf88c5e4a3877f9e96a.json"))
    stub_request(:get, file_url).to_return(status: 200, body: file_record)
    stub_request(:get, download_url).to_return(status: 200, body: pdf)
  end

  def run_in root, input = identifier
    described_class.new(input, root: root, client: client).run
  end

  describe '#run' do
    it 'writes the primary file, the OSF preprint record, and four sidecars, flat for v1' do
      Dir.mktmpdir do |root|
        dir = run_in root

        expect(dir).to eq File.join(root, paper_dir)
        expect(File.binread(File.join(dir, 'EIRMF_preprint.pdf'))).to eq pdf
        expect(File.read(File.join(dir, 'osf.json'))).to eq preprint
        %w[metadata.md metadata.yaml metadata.json metadata.bib].each do |name|
          expect(File).to exist File.join(dir, name)
        end
      end
    end

    it 'skips a version already archived' do
      Dir.mktmpdir do |root|
        run_in root
        run_in root

        expect(WebMock).to have_requested(:get, download_url).once
      end
    end

    context 'when the file does not match its SHA-256' do
      before { stub_request(:get, download_url).to_return(status: 200, body: 'not the preprint') }

      it 'raises ChecksumMismatch and leaves no paper folder' do
        Dir.mktmpdir do |root|
          expect { run_in root }.to raise_error OSF::Downloader::ChecksumMismatch
          expect(File).not_to exist File.join(root, paper_dir)
        end
      end
    end

    context 'when the preprint is a later version' do
      before do
        later = JSON.parse preprint
        later['data']['attributes']['version'] = 2
        stub_request(:get, preprint_url).to_return(status: 200, body: JSON.generate(later))
      end

      it 'archives it in its own v<N>/ folder' do
        Dir.mktmpdir do |root|
          expect(run_in(root)).to eq File.join(root, paper_dir, 'v2')
        end
      end
    end

    context 'when the preprint was withdrawn' do
      before do
        withdrawn = JSON.parse preprint
        withdrawn['data']['attributes']['date_withdrawn'] = '2026-09-01T00:00:00'
        stub_request(:get, preprint_url).to_return(status: 200, body: JSON.generate(withdrawn))
      end

      it 'raises NotAvailable and writes nothing' do
        Dir.mktmpdir do |root|
          expect { run_in root }.to raise_error OSF::Downloader::NotAvailable
          expect(Dir.children(root)).to be_empty
        end
      end
    end

    context 'when OSF has no such preprint' do
      before { stub_request(:get, 'https://api.osf.io/v2/preprints/zzzzz/').to_return(status: 404) }

      it 'raises PaperNotFound' do
        Dir.mktmpdir do |root|
          expect { run_in root, OSF::Downloader::Identifier.new('zzzzz') }.to raise_error OSF::Downloader::PaperNotFound
        end
      end
    end
  end
end
