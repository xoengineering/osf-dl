require_relative 'lib/osf/downloader/version'

Gem::Specification.new do |spec|
  spec.name    = 'osf-dl'
  spec.version = OSF::Downloader::VERSION
  spec.authors = ['Shane Becker']
  spec.email   = ['veganstraightedge@gmail.com']

  spec.summary     = 'Download preprints from OSF Preprints (PsyArXiv, SocArXiv, and more) for offline archives.'
  spec.description = <<~DESCRIPTION
    Command line tool and Ruby library for archiving preprints from OSF Preprints and the servers it hosts
    (PsyArXiv, SocArXiv, EarthArXiv, engrXiv, EdArXiv, and more), any version, with sidecar metadata.
  DESCRIPTION
  spec.homepage = 'https://github.com/xoengineering/osf-dl'

  spec.license = 'MIT'
  spec.required_ruby_version = '>= 4.0.7'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/xoengineering/osf-dl'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/xoengineering/osf-dl/issues'
  spec.metadata['changelog_uri']     = 'https://github.com/xoengineering/osf-dl/blob/main/CHANGELOG.md'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(
        *%w[
          .github/
          .gitignore
          .rspec
          .rubocop.yml
          .ruby-version
          Gemfile
          Rakefile
          bin/
          script/
          spec/
          tasks/
        ]
      )
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { File.basename it }
  spec.require_paths = ['lib']

  spec.add_dependency 'dl-core', '~> 0.2'
end
