source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'factory_girl_rails'
gem 'mysql'
gem 'rails'

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'capistrano', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-passenger', require: false
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
