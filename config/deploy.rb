# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'meal-planner.org'
set :repo_url, 'git@github.com:meal-planner/server.git'
set :deploy_to, '/var/www/meal-planner.org/api/'
set :unicorn_conf, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web) do
      exec "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
    end
  end

end
