RSpec.describe OSF::Downloader::PreprintParser do
  let(:fixtures) { 'spec/fixtures/http' }
  let(:parser) do
    described_class.new(
      preprint: File.read("#{fixtures}/preprint-cjy8e_v1.json"),
      citation: File.read("#{fixtures}/citation-cjy8e_v1.json"),
      license:  File.read("#{fixtures}/license-563c1cf88c5e4a3877f9e96a.json")
    )
  end
  let(:metadata) { parser.metadata }

  describe '#metadata' do
    it 'extracts the ID, version, provider, and URLs' do
      expect(metadata.osf_id).to  eq 'cjy8e'
      expect(metadata.version).to eq 1
      expect(metadata.provider).to eq 'psyarxiv'
      expect(metadata.osf_url).to eq 'https://osf.io/preprints/psyarxiv/cjy8e_v1/'
      expect(metadata.preprint_doi).to eq '10.31234/osf.io/cjy8e_v1'
    end

    it 'extracts the title, abstract, and dates' do
      expect(metadata.title).to start_with 'Exploratory Item Response Matrix Factorization'
      expect(metadata.abstract).not_to be_empty
      expect(metadata.published).to match(/\A\d{4}-\d{2}-\d{2}\z/)
    end

    it 'extracts authors from the citation as "Family, Given"' do
      expect(metadata.authors.map(&:name)).to eq ['Chen, Changsheng', 'Van Den Noortgate, Wim']
    end

    it 'extracts the license name and subjects' do
      expect(metadata.license).to eq 'CC-By Attribution 4.0 International'
      expect(metadata.subjects).to include 'Social and Behavioral Sciences', 'Quantitative Methods'
    end
  end

  describe 'related URLs' do
    it 'links the primary file, citation, and license' do
      expect(described_class.related_urls(File.read("#{fixtures}/preprint-cjy8e_v1.json"))).to eq(
        primary_file: 'https://api.osf.io/v2/files/6abb891cf1ccf5076851ef9b/',
        citation:     'https://api.osf.io/v2/preprints/cjy8e_v1/citation/',
        license:      'https://api.osf.io/v2/licenses/563c1cf88c5e4a3877f9e96a/'
      )
    end
  end

  describe '#available?' do
    it 'is true for a published preprint' do
      expect(parser).to be_available
    end

    it 'is false for a withdrawn preprint' do
      withdrawn = JSON.parse File.read("#{fixtures}/preprint-cjy8e_v1.json")
      withdrawn['data']['attributes']['date_withdrawn'] = '2026-09-01T00:00:00'
      parser = described_class.new(
        preprint: JSON.generate(withdrawn),
        citation: File.read("#{fixtures}/citation-cjy8e_v1.json"),
        license:  File.read("#{fixtures}/license-563c1cf88c5e4a3877f9e96a.json")
      )

      expect(parser).not_to be_available
    end
  end
end
