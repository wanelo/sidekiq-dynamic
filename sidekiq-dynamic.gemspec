# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/dynamic/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-dynamic"
  spec.version       = Sidekiq::Dynamic::VERSION
  spec.authors       = ["André Arko & Jo Pu"]
  spec.email         = ["andre+jo@wanelo.com"]
  spec.summary       = %q{Extends Sidekiq workers to allow dynamic queue and shard choice.}
  spec.description   = %q{Sidekiq-dynamic creates a subclass of Sidekiq::Worker, named Sidekiq::Dynamic::Worker, that allows each worker class to run code that determines which queue and Redis shard a job will be sent to.}
  spec.homepage      = "http://www.github.com/wanelo/sidekiq-dynamic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", "> 3.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
end
