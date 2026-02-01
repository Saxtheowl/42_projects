# frozen_string_literal: true

require_relative "lib/ft_wikipedia/version"

Gem::Specification.new do |spec|
  spec.name          = "ft_wikipedia"
  spec.version       = FtWikipedia::VERSION
  spec.authors       = ["Student"]
  spec.email         = ["student@42.fr"]

  spec.summary       = "Wikipedia Philosophy Route Finder"
  spec.description   = "Find the path to Philosophy on Wikipedia"
  # spec.homepage      = "https://github.com/example/ft_wikipedia"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.3.0"

  # spec.metadata["allowed_push_host"] = "https://rubygems.org"
  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "Rakefile"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.13"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
