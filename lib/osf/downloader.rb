require 'dl/core'

require_relative 'downloader/error'             # before the errors below that subclass Error
require_relative 'downloader/version'           # before client: Client::USER_AGENT uses VERSION

require_relative 'downloader/archive'
require_relative 'downloader/bibtex'
require_relative 'downloader/checksum_mismatch' # after error
require_relative 'downloader/client'            # after version
require_relative 'downloader/file_parser'
require_relative 'downloader/identifier'        # after error
require_relative 'downloader/markdown_body'
require_relative 'downloader/metadata'
require_relative 'downloader/not_available'     # after error
require_relative 'downloader/paper_not_found'   # after error
require_relative 'downloader/path'
require_relative 'downloader/preprint_parser'

module OSF
  module Downloader
  end
end
