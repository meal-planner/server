# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'meal-planner.org'
set :repo_url, 'git@github.com:meal-planner/server.git'
set :deploy_to, '/var/www/meal-planner.org/server/'
set :log_level, :info

namespace :unicorn do
  pid_path = "#{shared_path}/pids"
  unicorn_pid = "#{pid_path}/unicorn.pid"

  def run_unicorn
    execute "cd #{release_path}/config && ~/.rvm/bin/rvm default do unicorn -c unicorn.rb -D -E #{fetch(:stage)}"
  end

  desc 'Start unicorn'
  task :start do
    on roles(:app) do
      run_unicorn
    end
  end

  desc 'Stop unicorn'
  task :stop do
    on roles(:app) do
      if test "[ -f #{unicorn_pid} ]"
        execute :kill, "-QUIT `cat #{unicorn_pid}`"
      end
    end
  end

  desc 'Force stop unicorn (kill -9)'
  task :force_stop do
    on roles(:app) do
      if test "[ -f #{unicorn_pid} ]"
        execute :kill, "-9 `cat #{unicorn_pid}`"
        execute :rm, unicorn_pid
      end
    end
  end

  desc 'Restart unicorn'
  task :restart do
    on roles(:app) do
      if test "[ -f #{unicorn_pid} ]"
        execute :kill, "-USR2 `cat #{unicorn_pid}`"
      else
        run_unicorn
      end
    end
  end
end

after 'deploy:publishing', 'unicorn:restart'
