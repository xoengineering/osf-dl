require 'osf/downloader'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Specs tagged :live hit the real OSF API. Run them with: OSF_LIVE=1
  config.filter_run_excluding :live unless ENV['OSF_LIVE']
end
