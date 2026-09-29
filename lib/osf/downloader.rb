require 'dl/core'

require_relative 'downloader/error'      # before the errors below that subclass Error
require_relative 'downloader/version'

require_relative 'downloader/identifier' # after error

module OSF
  module Downloader
  end
end
