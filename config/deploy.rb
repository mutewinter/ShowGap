require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, 'showgap'
set :deploy_to, '/srv/www/showgap.com'
set :repository, 'ssh://git@github.com:mutewinter/showgap.git'
set :shared_paths, ['log']

desc 'Load the environment variables from .bashrc'
task :env do
  queue %{
    echo "-----> Loading environment"
    #{echo_cmd %[source ~/.environment]}
  }
end

desc "Deploys the current version to the server."
task :deploy do
  invoke :env

  deploy do
    invoke :'git:clone'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'deploy:link_shared_paths'
      invoke :symlink_nginx
      invoke :'nginx:restart'
      # TODO Restart unicorn in zero-downtime fashion
    end
  end
end

desc 'Symlink nginx.conf into the nginx folder.'
task :symlink_nginx do
  queue %{
    echo "-----> Linking nginx.conf"
    #{echo_cmd %[sudo ln -sf "#{deploy_to}/#{current_path}/config/nginx.conf" /etc/nginx/sites-enabled/showgap]}
  }
  to :clean do
    queue %{
      echo "Reverting nginx.conf link to $previous_path"
      [ -n "$previous_path" ] && sudo ln -sf "$previous_path/nginx.conf" /etc/nginx/sites-enabled/showgap
    }
  end
end

desc 'Stop, start, and restart nginx.'
namespace :nginx do
  [:start, :stop, :restart].each do |task|
    task task do
      queue %{
        echo "-----> #{task.to_s} nginx"
        sudo service nginx #{task.to_s}
      }
    end
  end
end
