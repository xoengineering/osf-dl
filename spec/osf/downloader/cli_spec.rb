# Option parsing, --input, and error reporting are specified in dl-core.
RSpec.describe OSF::Downloader::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  it 'defaults to one request every 36 seconds, for OSF’s anonymous API limit' do
    expect(described_class.new([]).default_rate_limit).to eq 36
  end

  it "uses osf-dl's usage line and version" do
    described_class.new(['-h'], stderr:, stdout:).run
    described_class.new(['--version'], stderr:, stdout:).run

    expect(stdout.string).to start_with 'Usage: osf-dl [options] <OSF_ID_OR_URL>'
    expect(stdout.string).to end_with "#{OSF::Downloader::VERSION}\n"
  end

  it 'reports an unrecognized target and exits non-zero' do
    expect(described_class.new(['not-an-id'], stderr:, stdout:).run).to eq 1
    expect(stderr.string).to eq "not-an-id: not an OSF preprint identifier: not-an-id\n"
  end
end
