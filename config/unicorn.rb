# Unicorn Web Server Configuration
#
# These links provided the genesis for this configuration:
#
#  - http://unicorn.bogomips.org/examples/unicorn.conf.rb
#  - http://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn
#  - http://blog.railsonfire.com/2012/05/06/Unicorn-on-Heroku.html

current_path = '/srv/www/showgap.com/current'
pid_name = 'unicorn.showgap'

worker_processes 4
preload_app true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# Help ensure your application will always spawn in the symlinked "current"
# directory that Mina sets up.
working_directory current_path

listen '/tmp/unicorn.showgap.sock'
pid "/var/run/unicorn/#{pid_name}.pid"

# Log to current folder which is symlinked to shared directory by Mina.
stdout_path "#{current_path}/log/unicorn.log"
stderr_path "#{current_path}/log/unicorn_error.log"

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/tmp/#{pid_name}.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
