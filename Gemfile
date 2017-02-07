source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'factory_girl_rails'
gem 'mysql'
gem 'rails'

group :production do
  gem 'exception_notification'
end

group :development do
  # deployment
  gem 'capistrano', '~> 3.3.0'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'mocha'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-cops'
end
