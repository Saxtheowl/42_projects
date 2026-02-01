# frozen_string_literal: true

require_relative "lib/deepthought/version"

Gem::Specification.new do |spec|
  spec.name          = "deepthought"
  spec.version       = Deepthought::VERSION
  spec.authors       = ["Student"]
  spec.email         = ["student@42.fr"]

  spec.summary       = "A gem that answers the ultimate question"
  spec.description   = "Deep Thought answers the ultimate question of life, the universe and everything"
  # spec.homepage      = "https://example.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "https://example.com"
  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "https://example.com"
  # spec.metadata["changelog_uri"] = "https://example.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize", "~> 1.1"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
