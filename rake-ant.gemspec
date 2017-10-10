# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rake/ant/version"

Gem::Specification.new do |spec|
  spec.name          = "rake-ant"
  spec.version       = Rake::Ant::VERSION
  spec.authors       = ["Thomas E Enebo", "Charles Oliver Nutter"]
  spec.email         = ["tom.enebo@gmail.com", "headius@headius.com"]

  spec.summary       = %q{Ant tasks and integration for Rake}
  spec.homepage      = "https://github.com/jruby/rake-ant"

  spec.license       = "EPL-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
