set :application, 'scheduler'

set :scm, :git
set :git_username, 'mlynch6'
set :git_email, 'mlynch6@hotmail.com'
set :repo_url, 'https://mlynch6:g3ZGA2BRevtnU@github.com/mlynch6/Scheduler.git'
set :branch, 'master'

set :deploy_to, '/var/www/danceware'
set :keep_releases, 10

set :rbenv_bootstrap, 'bootstrap-ubuntu-12-04'
set :ruby_version, '1.9.3-p429'
set :rails_env, 'production'

ask :db_password, "change_me"
ask :db_ip, "localhost"

ask :stripe_private_key, "sk_test_key"
ask :stripe_public_key, "pk_test_key"

set :format, :pretty
set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/initializers/stripe.rb config/nginx.conf config/unicorn.rb config/unicorn_init.sh}
set :linked_dirs, %w{bin} # log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }

SSHKit.config.command_map[:rake]	= "bundle exec rake"
SSHKit.config.command_map[:rails]	= "bundle exec rails"

namespace :deploy do

  desc 'Restart application'
  task :restart do
  	invoke 'nginx:restart'
  	invoke 'unicorn:restart'
	end
end
