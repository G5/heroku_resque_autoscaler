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
        tries = 0
        begin
          tries += 1
          heroku.get_ps(app_name).body.keep_if do |ps|
            ps["process"] =~ /worker/
          end.length.to_i
        rescue ::Heroku::API::Errors::RateLimitExceeded => e
          if tries < HerokuResqueAutoscaler.configuration["heroku_max_retry"].to_i
            sleep(HerokuResqueAutoscaler.configuration["heroku_retry_rate"].to_f)
            retry
          else
            raise e
          end
        end
      end

      def workers=(qty)
        tries = 0
        begin
          tries += 1
          heroku.post_ps_scale(app_name, :worker, qty)
        rescue ::Heroku::API::Errors::RateLimitExceeded => e
          if tries < HerokuResqueAutoscaler.configuration["heroku_max_retry"].to_i
            sleep(HerokuResqueAutoscaler.configuration["heroku_retry_rate"].to_f)
            retry
          else
            raise e
          end
        end
      end

      def job_count
        Resque.info[:pending].to_i
      end

      def working_job_count
        Resque.info[:working].to_i
      end
    end
  end
end
