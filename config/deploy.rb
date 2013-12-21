set :application, 'scheduler'

set :scm, :git
set :git_username, 'mlynch6'
set :git_email, 'mlynch6@hotmail.com'
set :repo_url, 'https://mlynch6:g3ZGA2BRevtnU@github.com/mlynch6/Scheduler.git'
set :branch, 'master'

set :deploy_to, '/var/www/danceware'
set :keep_releases, 20

set :format, :pretty
set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/unicorn.rb}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :rbenv_bootstrap, 'bootstrap-ubuntu-12-04'
set :ruby_version, '1.9.3-p429'
set :rails_env, 'production'

ask :db_password, "change_me"
ask :db_ip, "111.111.111"

SSHKit.config.command_map[:rake]	= "bundle exec rake"
SSHKit.config.command_map[:rails]	= "bundle exec rails"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:restart'
    end
    
		on roles(:web), in: :sequence, wait: 10 do
			invoke 'nginx:restart'
		end
	end

  after :finishing, 'deploy:cleanup'
end
