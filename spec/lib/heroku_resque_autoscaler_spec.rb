require 'spec_helper'
require 'heroku_resque_autoscaler'

describe HerokuResqueAutoscaler do
  it { should respond_to :configuration }
  it { should respond_to :configure }

  describe "::configuration" do
    it "should be the configuration object" do
      HerokuResqueAutoscaler.configuration.should(
        be_a_kind_of HerokuResqueAutoscaler::Configuration)
    end

    it "give a new instance if non defined" do
      HerokuResqueAutoscaler.configuration = nil
      HerokuResqueAutoscaler.configuration.should(
        be_a_kind_of HerokuResqueAutoscaler::Configuration)
    end
  end

  describe "::configure" do
    it "should yield the configuration object" do
      HerokuResqueAutoscaler.configure do |config|
        config.should equal(HerokuResqueAutoscaler.configuration)
      end
    end
  end
end
