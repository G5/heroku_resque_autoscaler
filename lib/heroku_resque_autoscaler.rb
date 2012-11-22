require "heroku_resque_autoscaler/version"
require "heroku_resque_autoscaler/configuration"
require "heroku_resque_autoscaler/scaler"

module HerokuResqueAutoscaler
  class << self
    # A HerokuResqueAutoscaler configuration object. Must act like a hash and 
    # return sensible values for all HerokuResqueAutoscaler configuration options.
    #
    # @see HerokuResqueAutoscaler::Configuration.
    attr_writer :configuration

    # The configuration object.
    #
    # @see HerokuResqueAutoscaler.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   HerokuResqueAutoscaler.configure do |config|
    #     config.heroku_api_key  = ENV["HEROKU_API_KEY"]
    #     config.heroku_app_name = ENV["HEROKU_APP_NAME"]
    #   end
    def configure
      yield(configuration)
    end
  end
end
