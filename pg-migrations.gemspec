# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pg/migrations/version"

Gem::Specification.new do |spec|

  spec.name          = "pg-migrations"
  spec.version       = Pg::Migrations::VERSION
  spec.authors       = ["Jorge Morais"]
  spec.email         = ["jorge.morais@cldware.com"]

  spec.summary       = "Implements ActiveRecord-like migrations without using ActiveRecord, for pg-databased Ruby applications"
  spec.homepage      = "https://github.com/jorgecsrmorais/pg-migrations"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake"

end
