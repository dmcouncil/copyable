# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'copyable/version'

Gem::Specification.new do |spec|
  spec.name          = "copyable"
  spec.version       = Copyable::VERSION
  spec.authors       = ["Wyatt Greene", "Dennis Chan", "Anne Geiersbach", "Parker Morse"]
  spec.email         = ["dchan@dmgroupK12.com", "ageiersbach@dmgroupK12.com", "pmorse@dmgroupK12.com"]
  spec.summary       = %q{ActiveRecord copier}
  spec.description   = %q{Copyable makes it easy to copy ActiveRecord models.}
  spec.homepage      = "https://github.com/dmcouncil/copyable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "5.2.6"

  spec.add_development_dependency "database_cleaner", "~> 2"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3", "~> 1.3.6"
end
