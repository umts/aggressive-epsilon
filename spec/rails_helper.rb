ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'factory_girl_rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'support/reservation_helper.rb'
include ReservationHelper

ActiveRecord::Migration.maintain_test_schema!
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include ReservationHelper
end
