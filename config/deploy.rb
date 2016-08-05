# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'meal-planner.org'
set :repo_url, 'git@github.com:meal-planner/server.git'
set :deploy_to, '/var/www/meal-planner.org/server/'
set :log_level, :info

namespace :deploy do
  desc 'Copy NewRelic config file'
  task :copy_config do
    on roles(:app) do
      execute :cp, "#{shared_path}/newrelic.yml", "#{release_path}/config"
      execute :cp, "#{shared_path}/.env", "#{release_path}/config"
      execute :cp, "#{shared_path}/client_secrets.json", "#{release_path}/config"
    end
  end
end

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

before 'deploy:publishing', 'deploy:copy_config'
after 'deploy:publishing', 'unicorn:restart'
