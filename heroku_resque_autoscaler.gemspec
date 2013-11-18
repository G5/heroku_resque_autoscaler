# -*- encoding: utf-8 -*-
require File.expand_path('../lib/heroku_resque_autoscaler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "heroku_resque_autoscaler"
  gem.version       = HerokuResqueAutoscaler::VERSION
  gem.authors       = ["Jessica Lynn Suttles"]
  gem.email         = ["jlsuttles@gmail.com"]
  gem.description   = %q{Uses Resque Job Hooks and the Heroku API gem to autoscale Heroku Resque workers}
  gem.summary       = %q{Uses Resque Job Hooks and the Heroku API gem to autoscale Heroku Resque workers}
  gem.homepage      = "https://github.com/G5/heroku_resque_autoscaler"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "heroku-api", "~> 0.3.5"
  gem.add_dependency "resque", "~> 1.23.0"

  gem.add_development_dependency "simplecov", "~> 0.7.1"
  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "guard-rspec", "~> 2.1.0"
  gem.add_development_dependency "rb-fsevent", "~> 0.9.2"
end
