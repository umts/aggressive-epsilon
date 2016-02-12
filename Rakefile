require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

unless Rails.env.production?
  require 'rubocop/rake_task'
  require 'rspec/core/rake_task'

  namespace :style do
    desc 'Run Ruby style checks'
    RuboCop::RakeTask.new
  end

  namespace :rspec do
    desc 'Run RSpec'
    RSpec::Core::RakeTask.new
  end

  desc 'The style and functionality check which Travis performs'
  task travis: %w(rspec:spec style:rubocop)
end
