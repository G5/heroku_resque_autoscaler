require "heroku-api"
require "resque"

module HerokuResqueAutoscaler
  module Scaler
    class << self
      # TODO: use HerokuResqueAutoscaler.configuration for api_key
      @@heroku = Heroku::API.new(api_key: ENV["HEROKU_API_KEY"])

      def api_key
        HerokuResqueAutoscaler.configuration["heroku_api_key"]
      end

      def app_name
        HerokuResqueAutoscaler.configuration["heroku_app_name"]
      end

      def workers
        @@heroku.get_ps(app_name).body.keep_if do |ps|
          ps["process"] =~ /worker/
        end.length.to_i
      end

      def workers=(qty)
        @@heroku.post_ps_scale(app_name, :worker, qty)
      end

      def job_count
        Resque.info[:pending].to_i
      end

      def working_job_count
        Resque.info[:working].to_i
      end
    end
  end

  def after_perform_scale_down(*args)
    # Scale everything down if we have no pending jobs and one working job (this one)
    Scaler.workers = 0 if Scaler.job_count.zero? && Scaler.working_job_count == 1
  end

  def num_desired_heroku_workers(*args)
    [
      {
        :workers => 1, # This many workers
        :job_count => 1 # For this many jobs or more, until the next level
      },
      {
        :workers => 2,
        :job_count => 15
      },
      {
        :workers => 3,
        :job_count => 25
      },
      {
        :workers => 4,
        :job_count => 40
      },
      {
        :workers => 5,
        :job_count => 60
      }
    ].reverse_each do |scale_info|
      if Scaler.job_count >= scale_info[:job_count]
        return scale_info[:workers]
      end
    end
  end

  def after_enqueue_scale_up(*args)
    desired_workers = num_desired_heroku_workers
    if Scaler.workers < desired_workers
      Scaler.workers = desired_workers
    end
  end
end
