RSpec.describe OSF::Downloader::Identifier do
  describe '.new' do
    {
      'cjy8e'                                       => ['cjy8e', nil],
      ' cjy8e_v1 '                                  => ['cjy8e', 1],
      'https://osf.io/preprints/psyarxiv/cjy8e_v1/' => ['cjy8e', 1],
      'https://osf.io/preprints/socarxiv/cjy8e'     => ['cjy8e', nil],
      'osf.io/cjy8e'                                => ['cjy8e', nil],
      'https://osf.io/cjy8e_v2'                     => ['cjy8e', 2],
      'https://api.osf.io/v2/preprints/cjy8e_v1/'   => ['cjy8e', 1],
      '10.31234/osf.io/cjy8e_v1'                    => ['cjy8e', 1],
      'https://doi.org/10.31234/osf.io/cjy8e'       => ['cjy8e', nil],
      'doi:10.31219/osf.io/cjy8e'                   => ['cjy8e', nil]
    }.each do |input, (id, version)|
      it "parses #{input.inspect}" do
        identifier = described_class.new input

        expect([identifier.id, identifier.version]).to eq [id, version]
      end
    end

    [nil, '', 'not an id', 'CJY8E', 'cjy8', 'https://example.com/cjy8e', '10.1000/example.org/cjy8e'].each do |input|
      it "rejects #{input.inspect}" do
        expect { described_class.new input }.to raise_error described_class::Invalid
      end
    end
  end

  describe '#to_s' do
    it 'is the API form, with the version when one was given' do
      expect(described_class.new('cjy8e').to_s).to    eq 'cjy8e'
      expect(described_class.new('cjy8e_v1').to_s).to eq 'cjy8e_v1'
    end
  end
end
