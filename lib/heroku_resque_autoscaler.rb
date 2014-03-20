require "heroku_resque_autoscaler/version"
require "heroku_resque_autoscaler/configuration"
require "heroku_resque_autoscaler/scaler"

module HerokuResqueAutoscaler
    WORKER_SCALE = [
      { :workers => 1, :job_count => 1 },
      { :workers => 2, :job_count => 15 },
      { :workers => 3, :job_count => 25 },
      { :workers => 4, :job_count => 40 },
      { :workers => 5, :job_count => 60 }
    ]

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

  def after_enqueue_scale_up(*args)
    desired_workers = num_desired_heroku_workers
    if Scaler.workers < desired_workers
      Scaler.workers = desired_workers
    end
  end

  def after_perform_scale_down(*args)
    # Scale everything down if we have no pending jobs and one working job (this one)
    Scaler.workers = 0 if Scaler.job_count.zero? && Scaler.working_job_count == 1
  end

  def num_desired_heroku_workers(*args)
    WORKER_SCALE.reverse_each do |scale_info|
      if Scaler.job_count >= scale_info[:job_count]
        return scale_info[:workers]
      end
    end

    0
  end
end
