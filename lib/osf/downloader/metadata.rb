module OSF
  module Downloader
    # Field order is the reading order of the metadata sidecars.
    Metadata = Data.define(
      :osf_id,
      :version,
      :provider,
      :osf_url,
      :preprint_doi,
      :doi,
      :title,
      :authors,
      :abstract,
      :published,
      :subjects,
      :tags,
      :license
    )
  end
end
