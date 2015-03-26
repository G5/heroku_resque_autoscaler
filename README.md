# Heroku Resque Autoscaler

[![Build Status](https://travis-ci.org/G5/heroku_resque_autoscaler.png)](https://travis-ci.org/G5/heroku_resque_autoscaler)
[![Code Climate](https://codeclimate.com/github/G5/heroku_resque_autoscaler.png)](https://codeclimate.com/github/G5/heroku_resque_autoscaler)

Uses Resque Job Hooks and the Heroku API gem to autoscale Heroku Resque workers

Inspired by [@darkhelmet](https://github.com/darkhelmet)'s
[Auto-scale Your Resque Workers On Heroku](http://verboselogging.com/2010/07/30/auto-scale-your-resque-workers-on-heroku)


## Current Version

0.1.2


## Requirements

* ["heroku_api", "~> 0.3.5"](http://rubygems.org/gems/heroku-api)
* ["resque", "~> 1.23.0"](http://rubygems.org/gems/resque)


## Installation

### Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'heroku_resque_autoscaler'
```

### Manual

Or install it yourself:

```bash
gem install heroku_resque_autoscaler
```


## Usage

Set defaults in an initializer, defaults are shown:

```ruby
HerokuResqueAutoscaler.configure do |config|
  config.heroku_api_key  = ENV["HEROKU_API_KEY"]
  config.heroku_app_name = ENV["HEROKU_APP_NAME"]
  config.heroku_max_retry: ENV["HEROKU_MAX_RETRY"] ||= "5",
  config.heroku_retry_rate: ENV["HEROKU_RETRY_RATE"] ||= "10"
end
```

Export you environment variables wherever you do that:

```bash
export HEROKU_API_KEY=heroku_api_key
export HEROKU_APP_NAME=heroku_app_name
```

Your Resque workers should extend HerokuResqueAutoscaler:

```ruby
class AutoscaledJob
  extend HerokuResqueAutoscaler

  def self.perform
    # Do something
  end
end
```


## Authors

  * Jessica Lynn Suttles / [@jlsuttles](https://github.com/jlsuttles)
  * Bookis Smuin / [@bookis](https://github.com/bookis)


## Contributing

1. Fork it
2. Get it running
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Write your code and **specs**
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/G5/heroku_resque_autoscaler/issues).


## Specs

```bash
rspec spec
```


## Coverage

```bash
rspec spec
open coverage/index.html
```

## Releases

```bash
vi lib/heroku_resque_autoscaler/version.rb # change version
vi README.md # change version
rake release
```


## License

Copyright (c) 2012 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
