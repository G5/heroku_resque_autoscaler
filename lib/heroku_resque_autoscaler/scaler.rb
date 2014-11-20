require "heroku-api"
require "resque"

module HerokuResqueAutoscaler
  module Scaler
    class << self
      def heroku
        @heroku ||= Heroku::API.new(api_key: api_key)
      end

      def api_key
        HerokuResqueAutoscaler.configuration["heroku_api_key"]
      end

      def app_name
        HerokuResqueAutoscaler.configuration["heroku_app_name"]
      end

      def workers
        heroku.get_ps(app_name).body.keep_if do |ps|
          ps["process"] =~ /worker/
        end.length.to_i
      end

      def workers=(qty)
        heroku.post_ps_scale(app_name, :worker, qty)
      end

      def job_count
        Resque.info[:pending].to_i
      end

      def working_job_count
        Resque.info[:working].to_i
      end

      def ready_to_scale_down?
        job_count.zero? && working_job_count == 1
      end
    end
  end
end
