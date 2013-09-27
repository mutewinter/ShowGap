require 'fileutils'

def go
  unicorn_folder = '/var/run/unicorn'

  if !File.directory?(unicorn_folder)
    banner "Creating #{unicorn_folder}"
    File.mkdir unicorn_folder
  end

  chown_g unicorn_folder, 'derploy', 'sudo'
end


def chown_g(file, user, group)
  user = user.to_s
  # who is the current owner?
  @uids ||= {}
  @uids[user] ||= Etc.getpwnam(user).uid
  uid = @uids[user]
  if File.stat(file).uid != uid
    run "chown #{user}:#{group || user} '#{file}'"
  end
end

go
