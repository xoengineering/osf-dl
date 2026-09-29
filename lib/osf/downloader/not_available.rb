module OSF
  module Downloader
    class NotAvailable < Error
      def initialize message = 'withdrawn or unpublished on OSF'
        super
      end
    end
  end
end
