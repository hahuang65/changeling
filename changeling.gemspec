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

  # Dependencies
  gem.add_dependency "tire", "~> 0.5.3"
  gem.add_dependency "activemodel"

  # Development Dependencies
  case RUBY_VERSION
  when "1.9.3"
    gem.add_development_dependency "mongoid", "3.0.3"
    gem.add_development_dependency "activerecord", "3.2.7"
    gem.add_development_dependency "debugger"
    gem.add_development_dependency "sidekiq", "3.2.1"
  end
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "bson_ext"
  gem.add_development_dependency "database_cleaner"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rails"
  gem.add_development_dependency "resque"
end
