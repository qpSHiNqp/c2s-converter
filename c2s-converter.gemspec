
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "c2s/converter/version"

Gem::Specification.new do |spec|
  spec.name          = "c2s-converter"
  spec.version       = C2s::Converter::VERSION
  spec.authors       = ["Shintaro Tanaka"]
  spec.email         = ["tallow@dirt.ninja"]

  spec.summary       = %q{Conversion tool for those who want to replace chatwork with slack.}
  spec.description   = %q{Converts chatwork-style markups in exported data into slack-style markups.}
  spec.homepage      = "https://github.com/qpSHiNqp/c2s-converter"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "chatwork_to_slack"
end
