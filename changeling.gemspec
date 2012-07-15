# -*- encoding: utf-8 -*-
require File.expand_path('../lib/changeling/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Howard Huang"]
  gem.email         = ["hahuang65@gmail.com"]
  gem.description   = %q{A simple, yet flexible solution to tracking changes made to objects in your database.}
  gem.summary       = %q{Object change-logger}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "changeling"
  gem.require_paths = ["lib"]
  gem.version       = Changeling::VERSION
end
