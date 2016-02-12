%w(bundler deploy rbenv passenger setup).each { |r| require "capistrano/#{r}" }
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
