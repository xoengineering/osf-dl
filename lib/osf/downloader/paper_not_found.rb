module OSF
  module Downloader
    class PaperNotFound < Error
      def initialize message = 'no such preprint on OSF'
        super
      end
    end
  end
end
