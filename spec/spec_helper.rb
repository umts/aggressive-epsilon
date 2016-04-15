require 'codeclimate-test-reporter'
require 'factory_girl_rails'
require 'simplecov'
require 'rspec'

CodeClimate::TestReporter.start if ENV['CI']
SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before :all do
    FactoryGirl.reload
  end
  config.include FactoryGirl::Syntax::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def authenticate!(service: create(:service))
  request.headers['Authorization'] = "Token token=#{service.api_key}"
  service
end

def authenticate_with_access_to(access_type, item_type)
  service = create :service
  unless %i(read write).include? access_type
    raise 'Valid access types are read and write'
  end
  attrs = { service: service, item_type: item_type }
  attrs[:write] = true if access_type == :write
  create :permission, attrs
  authenticate! service: service
  service
end

def deauthenticate!
  request.headers['Authorization'] = nil
end

