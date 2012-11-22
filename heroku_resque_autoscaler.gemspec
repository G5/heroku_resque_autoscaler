# -*- encoding: utf-8 -*-
require File.expand_path('../lib/heroku_resque_autoscaler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jessica Lynn Suttles"]
  gem.email         = ["jlsuttles@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "heroku_resque_autoscaler"
  gem.require_paths = ["lib"]
  gem.version       = HerokuResqueAutoscaler::VERSION
end
