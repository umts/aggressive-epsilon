require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(*Rails.groups)

module AggressiveEpsilon
  class Application < Rails::Application
    config.api_only = true
    config.encoding = 'utf-8'
    config.time_zone = 'Eastern Time (US & Canada)'
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += Dir["#{Rails.root}/spec/**/"]
    config.filter_parameters += %i(password secret spire github)
  end
end
