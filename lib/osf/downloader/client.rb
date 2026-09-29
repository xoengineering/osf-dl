module OSF
  module Downloader
    # DL::Core::Client with osf-dl's User-Agent filled in. OSF limits anonymous API use
    # to about 100 requests an hour, so the default is one request every 36 seconds.
    class Client < DL::Core::Client
      SOURCE_URL         = 'https://github.com/xoengineering/osf-dl'.freeze
      USER_AGENT         = "osf-dl/#{VERSION} (+#{SOURCE_URL})".freeze
      DEFAULT_RATE_LIMIT = 36

      def initialize log: nil, rate_limit: DEFAULT_RATE_LIMIT
        super(user_agent: USER_AGENT, log:, rate_limit:)
      end
    end
  end
end
