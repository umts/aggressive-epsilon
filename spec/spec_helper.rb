require 'codeclimate-test-reporter'
require 'factory_girl_rails'
require 'simplecov'

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
end

def authenticate_with_access_to(access_type, item_type)
  service = create :service
  unless %i(read write).include? access_type
    raise 'Valid access types are read and write'
  end
  create :permission, service: service, item_type: item_type,
                      access_type => true
  authenticate! service: service
end

def deauthenticate!
  request.headers['Authorization'] = nil
end

def default_start_time
  Date.yesterday.to_datetime
end

# By default reservations are 2 days in length
def default_end_time
  default_start_time + 2.days
end

# https://github.com/thoughtbot/factory_girl/issues/229#issuecomment-2696357
# Can't define factory traits based dynamically around default start and end
# times, so we define a helper method instead of that.
# Based on default reservations being 2 days long, we use the given type
# to shift the reservation around in the default range as needed.
def reservation_with_times(type)
  modifiers = case type
              when :starting_in_default_range then [-1, -1]
              when :ending_in_default_range   then [1, 1]
              when :spanning_default_range    then [-1, 1]
              when :not_during_default_range  then [-7, -7]
              end
  create :reservation,
         start_datetime: (default_start_time + modifiers.first.days),
         end_datetime: (default_end_time + modifiers.last.days)
end
