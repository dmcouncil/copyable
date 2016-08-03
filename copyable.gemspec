# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copyable/version'

Gem::Specification.new do |spec|
  spec.name          = "copyable"
  spec.version       = Copyable::VERSION
  spec.authors       = ["Wyatt Greene", "Dennis Chan"]
  spec.email         = ["dchan@dmcouncil.org"]
  spec.summary       = %q{ActiveRecord copier}
  spec.description   = %q{Copyable makes it easy to copy ActiveRecord models.}
  spec.homepage      = "https://github.com/dmcouncil/copyable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~>4.1"

  spec.add_development_dependency "database_cleaner", "~> 1.4.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
end
