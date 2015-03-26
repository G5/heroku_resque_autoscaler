require 'spec_helper'
require 'heroku_resque_autoscaler'
require 'heroku_resque_autoscaler/scaler'

require "spec_helper"

class HerokuResqueAutoscalerTestClass
  extend HerokuResqueAutoscaler
end

describe HerokuResqueAutoscaler do
  before :each do
    @heroku = mock(Heroku::API)
    HerokuResqueAutoscaler::Scaler.stub(:heroku).and_return(@heroku)

    HerokuResqueAutoscaler.configure do |config|
      config.heroku_api_key = "api-key"
      config.heroku_app_name = "app-name"
      config.heroku_max_retry= "5"
      config.heroku_retry_rate = "0.1"
    end
  end

  let(:heroku_app_name) { "app-name" }
  let(:api_rate_limit_response) do
    Excon.stub(method: :get) do |params|
      { status: 429,
        body: { "id" => "rate_limit", "error" => "Your account reached the API rate limit" }
      }
    end
    connection = Excon.new("http://example.com", mock: true)
    connection.request(method: :get)
  end

  context ".api_key" do
    it "returns api key" do
      HerokuResqueAutoscaler::Scaler.api_key.should == "api-key"
    end
  end

  context ".app_name" do
    it "returns app name" do
      HerokuResqueAutoscaler::Scaler.app_name.should == "app-name"
    end
  end

  context ".workers" do
    it "returns the number of workers from the Heroku application" do
      Excon.stub(method: :get) do |params|
        { status: 200,
          body: [
            {"process" => "web.1"},
            {"process" => "worker.1"},
            {"process" => "worker.2"},
          ]
        }
      end
      connection = Excon.new("http://example.com", mock: true)
      response = connection.request(method: :get)
      @heroku.should_receive(:get_ps).with(heroku_app_name).and_return(response)
      HerokuResqueAutoscaler::Scaler.workers.should == 2
    end

    it "retries if the API rate limit is exceeded" do
      @heroku.stub(:get_ps)
        .and_raise(::Heroku::API::Errors::RateLimitExceeded.new('message', api_rate_limit_response))
      @heroku.should_receive(:get_ps).with(heroku_app_name).exactly(5).times
      lambda { HerokuResqueAutoscaler::Scaler.workers}.should raise_error
    end
  end

  context ".workers=" do
    it "sets the number of workers on Heroku to some quantity" do
      quantity = 10
      @heroku.should_receive(:post_ps_scale).with(heroku_app_name, :worker, quantity)
      HerokuResqueAutoscaler::Scaler.workers = quantity
    end

    it "retries if the API rate limit is exceeded" do
      @heroku.stub(:post_ps_scale)
        .and_raise(::Heroku::API::Errors::RateLimitExceeded.new('message', api_rate_limit_response))
      @heroku.should_receive(:post_ps_scale).exactly(5).times
      lambda { HerokuResqueAutoscaler::Scaler.workers = 0 }.should raise_error
    end
  end

  context ".job_count" do
    it "returns the Resque job count" do
      num_pending = 10
      Resque.should_receive(:info).and_return({:pending => num_pending})
      HerokuResqueAutoscaler::Scaler.job_count.should == num_pending
    end
  end

  context ".working_job_count" do
    it "returns the Resque working job count" do
      num_working = 10
      Resque.should_receive(:info).and_return({:working => num_working})
      HerokuResqueAutoscaler::Scaler.working_job_count.should == num_working
    end
  end

  context ".num_desired_heroku_workers" do
    it "returns the number of workers we should have (1 worker per x jobs)" do
      num_jobs = 100
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(num_jobs)
      HerokuResqueAutoscalerTestClass.num_desired_heroku_workers.should == 5

      num_jobs = 38
      HerokuResqueAutoscaler::Scaler.unstub(:job_count)
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(num_jobs)
      HerokuResqueAutoscalerTestClass.num_desired_heroku_workers.should == 3

      num_jobs = 1
      HerokuResqueAutoscaler::Scaler.unstub(:job_count)
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(num_jobs)
      HerokuResqueAutoscalerTestClass.num_desired_heroku_workers.should == 1

      num_jobs = 10000
      HerokuResqueAutoscaler::Scaler.unstub(:job_count)
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(num_jobs)
      HerokuResqueAutoscalerTestClass.num_desired_heroku_workers.should == 5
    end

    context "when Scaler.job_count returns 0" do
      it "returns 0" do
        num_jobs = 0
        HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(num_jobs)
        HerokuResqueAutoscalerTestClass.num_desired_heroku_workers.should == 0
      end
    end
  end

  context ".after_perform_scale_down" do
    it "scales down the workers to zero if there are no jobs pending" do
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(0)
      HerokuResqueAutoscaler::Scaler.stub(:workers).and_return(1)
      HerokuResqueAutoscaler::Scaler.stub(:working_job_count).and_return(1)
      HerokuResqueAutoscaler::Scaler.should_receive(:workers=).with(0)
      HerokuResqueAutoscalerTestClass.after_perform_scale_down
    end

    it "does not scale down the workers if there are jobs pending" do
      HerokuResqueAutoscaler::Scaler.stub(:job_count).and_return(1)
      HerokuResqueAutoscaler::Scaler.should_not_receive(:workers=)
      HerokuResqueAutoscalerTestClass.after_perform_scale_down
    end
  end

  context ".after_enqueue_scale_up" do
    it "ups the amount of workers if there are not enough" do
      num_workers = 5
      num_desired_workers = 6
      HerokuResqueAutoscaler::Scaler.stub(:workers).and_return(num_workers)
      HerokuResqueAutoscalerTestClass.stub(:num_desired_heroku_workers).and_return(num_desired_workers)
      HerokuResqueAutoscaler::Scaler.should_receive(:workers=).with(num_desired_workers)
      HerokuResqueAutoscalerTestClass.after_enqueue_scale_up
    end

    it "does not change the amount of workers if there more workers than needed" do
      num_workers = 6
      num_desired_workers = 5
      HerokuResqueAutoscaler::Scaler.stub(:workers).and_return(num_workers)
      HerokuResqueAutoscalerTestClass.stub(:num_desired_heroku_workers).and_return(num_desired_workers)
      HerokuResqueAutoscaler::Scaler.should_not_receive(:workers=)
      HerokuResqueAutoscalerTestClass.after_enqueue_scale_up
    end

    it "does not change the amount of workers if there are exactly the number required" do
      num_workers = 6
      num_desired_workers = 6
      HerokuResqueAutoscaler::Scaler.stub(:workers).and_return(num_workers)
      HerokuResqueAutoscalerTestClass.stub(:num_desired_heroku_workers).and_return(num_desired_workers)
      HerokuResqueAutoscaler::Scaler.should_not_receive(:workers=)
      HerokuResqueAutoscalerTestClass.after_enqueue_scale_up
    end
  end
end
