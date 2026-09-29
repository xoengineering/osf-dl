# osf-dl

Download preprints and metadata from [OSF Preprints](https://osf.io/preprints) for offline archives. OSF hosts many preprint servers, including PsyArXiv, SocArXiv, EarthArXiv, engrXiv, and EdArXiv. `osf-dl` works with all of them.

For each preprint version, `osf-dl` saves:

- The preprint's primary file, checked against the SHA-256 checksum OSF publishes for it
- OSF's own preprint record (`osf.json`), verbatim
- Four sidecar metadata files: `metadata.md`, `metadata.yaml`, `metadata.json`, `metadata.bib`

Any version can be archived, not just the latest. Withdrawn and unpublished preprints are not archived.

## OSF's terms and rate limit

The Center for Open Science's [terms of use](https://github.com/CenterForOpenScience/cos.io/blob/master/TERMS_OF_USE.md) offer a public API and license use of content marked public, "subject to patent, copyright and trademark law". Those are the terms as published on GitHub. The current terms at <https://osf.io/terms-of-use/> may differ. Each preprint's license is recorded as `license`.

OSF limits anonymous API use to about 100 requests an hour. Each preprint takes five requests (the preprint, its citation, its license, its file record, and the file). So `osf-dl` defaults to one request every 36 seconds, about three minutes per preprint. `--rate-limit` or `OSF_RATE_LIMIT` changes that, but going faster than OSF allows gets you HTTP 429 responses, which `osf-dl` retries with backoff.

## Installation

```sh
gem install osf-dl
```

## CLI usage

```sh
osf-dl <OSF_ID_OR_URL> [<OSF_ID_OR_URL>...]
```

Accepted input forms:

| Form                | Example                                          |
| ------------------- | ------------------------------------------------ |
| Preprint ID         | `cjy8e`, `cjy8e_v1`                              |
| Preprint URL        | `https://osf.io/preprints/psyarxiv/cjy8e_v1/`    |
| Short URL           | `https://osf.io/cjy8e`                           |
| API URL             | `https://api.osf.io/v2/preprints/cjy8e_v1/`      |
| DOI                 | `10.31234/osf.io/cjy8e_v1`                       |
| DOI URL             | `https://doi.org/10.31234/osf.io/cjy8e`          |

An unversioned ID archives the latest version. A versioned ID archives that version.

### Flags

| Flag                      | Description                                                                   |
| ------------------------- | ----------------------------------------------------------------------------- |
| `-i FILE`, `--input FILE` | Read IDs/URLs from FILE, one per line (`-` for stdin, blanks and `#` skipped) |
| `-p PATH`, `--path PATH`  | Root download directory                                                       |
| `--rate-limit SECONDS`    | Seconds between HTTP requests (default `36`, `0` disables throttling)         |
| `-v`, `--verbose`         | Print step lines and per-request URL/byte logs to stdout                      |
| `-q`, `--quiet`           | Print nothing to stdout. Errors still go to stderr.                           |
| `--version`               | Print the gem version and exit                                                |
| `-h`, `--help`            | Print help and exit                                                           |

`-v` and `-q` are mutually exclusive.

### Environment variables

| Variable            | Effect                                                          |
| ------------------- | --------------------------------------------------------------- |
| `OSF_DOWNLOAD_PATH` | Root download directory (default: `$HOME/Downloads/OSF_Papers`) |
| `OSF_RATE_LIMIT`    | Seconds between HTTP requests (default: `36`, `0` disables)     |

Precedence: CLI flag, then ENV var, then default.

### Errors and exit status

A target that fails (unrecognized ID, no such preprint, withdrawn or unpublished, checksum mismatch, HTTP error, network failure) is reported on stderr as `<target>: <message>`, and the remaining targets still download. Exit status is `0` when every target succeeds and `1` when any fails.

## Output layout

```txt
$OSF_DOWNLOAD_PATH/                     # default: $HOME/Downloads/OSF_Papers
  YYYY/MM/DD/<server>/<osf-id>-<slug>/
    <file>                              # the preprint's primary file
    osf.json                            # OSF's preprint record, verbatim
    metadata.md                         # YAML frontmatter + Markdown body
    metadata.yaml
    metadata.json
    metadata.bib                        # synthesized @misc with the preprint DOI
```

`YYYY/MM/DD` is the publication date. `<server>` is the OSF preprint server (`psyarxiv`, `socarxiv`, and so on). `<slug>` is derived from the title.

A preprint with only v1 archived is kept flat, as above. When it has more than one version, each version gets its own `v<N>/` folder with the same contents. Archiving a second version of a flat preprint first moves the existing files into `v<N>/`. A preprint whose latest version is v2 or later starts out in `v<N>/` folders.

Each version downloads into a sibling `.partial` folder and is renamed into place only when the file matched its checksum. Re-running skips versions already archived.

## Library usage

```ruby
require 'osf/downloader'

identifier = OSF::Downloader::Identifier.new 'https://osf.io/preprints/psyarxiv/cjy8e_v1/'
client     = OSF::Downloader::Client.new                  # 36-second rate limit by default
path       = OSF::Downloader::Archive.new(identifier, root: '/tmp/papers', client: client).run
```

## Development

```sh
script/setup    # install dependencies
script/test     # run specs and rubocop
script/console  # interactive prompt
```

Specs run offline against recorded fixtures in `spec/fixtures/http/`. The PDF fixture is the first 4 KB of the real file, and the archive spec sets the expected SHA-256 to match it.

## License

MIT. See [LICENSE.md](LICENSE.md).

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/version/3/0/) 3.0. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
