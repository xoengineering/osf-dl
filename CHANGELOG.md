## [0.1.0]

First version. Per-preprint offline archive of OSF Preprints (PsyArXiv, SocArXiv, EarthArXiv, engrXiv, EdArXiv, and more), any version, built on [dl-core](https://github.com/xoengineering/dl-core) 0.3.

- Accepts OSF preprint IDs with or without a version, osf.io preprint, short, and API URLs, and osf.io DOIs.
- Saves the primary file, verified against OSF's SHA-256 checksum, plus OSF's preprint record verbatim and four sidecar metadata files.
- Layout: `YYYY/MM/DD/<server>/<osf-id>-<slug>/`, flat for a preprint with only v1 archived, `v<N>/` folders otherwise.
- Withdrawn and unpublished preprints raise `OSF::Downloader::NotAvailable`. A checksum mismatch raises `OSF::Downloader::ChecksumMismatch` and leaves nothing behind.
- Defaults to one request every 36 seconds, for OSF's anonymous limit of about 100 requests an hour.
