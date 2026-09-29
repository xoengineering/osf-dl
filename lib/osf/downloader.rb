require 'dl/core'

require_relative 'downloader/error'           # before the errors below that subclass Error
require_relative 'downloader/version'

require_relative 'downloader/file_parser'
require_relative 'downloader/identifier'      # after error
require_relative 'downloader/metadata'
require_relative 'downloader/preprint_parser'

module OSF
  module Downloader
  end
end
