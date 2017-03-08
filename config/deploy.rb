# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'aggressive-epsilon'
set :repo_url, 'git@github.com:umts/aggressive-epsilon.git'
set :deploy_to, '/var/www/aggressive-epsilon'
set :rvm_type, :system
set :linked_files, %w{config/database.yml config/secrets.yml}
SSHKit.config.umask = '002'
remote_user = Net::SSH::Config.for('umaps-web2.oit.umass.edu')[:user] || ENV['USER']
set :tmp_dir, "/tmp/#{remote_user}"
