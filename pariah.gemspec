# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pariah/version'

Gem::Specification.new do |spec|
  spec.name          = 'pariah'
  spec.version       = Pariah::VERSION
  spec.authors       = ["Chris Hanks"]
  spec.email         = ['christopher.m.hanks@gmail.com']
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = 'https://github.com/pathgather/pariah'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'excon'
  spec.add_dependency 'pond'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'm'
end
