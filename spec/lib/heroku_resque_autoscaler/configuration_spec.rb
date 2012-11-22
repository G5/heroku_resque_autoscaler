require 'spec_helper'
require 'heroku_resque_autoscaler'
require 'heroku_resque_autoscaler/configuration'

describe HerokuResqueAutoscaler::Configuration do
  it { should respond_to :"[]" }
  it { should respond_to :to_hash }
  it { should respond_to :merge }

  it "provides default values" do
    assert_config_default :heroku_api_key, ENV["HEROKU_API_KEY"]
  end

  it "allows values to be overwritten" do
    assert_config_overridable :heroku_api_key
  end

  it "acts like a hash" do
    config = HerokuResqueAutoscaler::Configuration.new
    hash = config.to_hash
    HerokuResqueAutoscaler::Configuration::OPTIONS.each_pair do |key, value|
      config[key].should eq(hash[key])
    end
  end

  it "is mergable" do
    config = HerokuResqueAutoscaler::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should eq(hash.merge(:key => 'value'))
  end

  def assert_config_default(option, default_value, config = nil)
    config ||= HerokuResqueAutoscaler::Configuration.new
    config.send(option).should eq(default_value)
  end

  def assert_config_overridable(option, value = 'a value')
    config = HerokuResqueAutoscaler::Configuration.new
    config.send(:"#{option}=", value)
    config.send(option).should eq(value)
  end
end
