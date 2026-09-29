module OSF
  module Downloader
    class CLI < DL::Core::CLI
      def program = 'osf-dl'

      def target_name = 'OSF_ID_OR_URL'

      # OSF_DOWNLOAD_PATH, OSF_RATE_LIMIT
      def env_prefix = 'OSF'

      def default_path = File.join(Dir.home, 'Downloads', 'OSF_Papers')

      # OSF allows about 100 anonymous API requests an hour
      def default_rate_limit = Client::DEFAULT_RATE_LIMIT

      def version = VERSION

      def user_agent = Client::USER_AGENT

      def client_for(rate_limit:, log:) = Client.new(rate_limit:, log:)

      def identifier_for(target) = Identifier.new(target)

      def archive_for(identifier, root:, client:) = Archive.new(identifier, root:, client:)
    end
  end
end
