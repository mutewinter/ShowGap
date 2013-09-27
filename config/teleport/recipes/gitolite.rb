# gitolite.rb
#
# Sets up Gitolite on a Ubuntu server.
#
# Tested on Ubuntu Server 12.04.

GIT_USER = 'git'
GIT_HOME = "/home/#{GIT_USER}"

# --------------
# Setup
# --------------
def setup
  if !File.directory?(GIT_HOME)
    banner "Creating gitolite user, #{GIT_USER}."
    run "adduser \
--system \
--shell /bin/bash \
--gecos 'gitolite user' \
--group \
--disabled-password \
--home #{GIT_HOME} \
    #{GIT_USER}"
  else
    banner "Git user #{GIT_USER} already exists."
  end

  gitolite_folder = "#{GIT_HOME}/.gitolite"

  if !File.directory?(gitolite_folder)
    gitolite_repo = "#{GIT_HOME}/gitolite"

    if !File.directory?(gitolite_repo)
      banner 'Cloning Gitolite'
      run_as_git "git clone git://github.com/sitaramc/gitolite #{gitolite_repo}"
    else
      banner "Gitolite directory already exists in #{gitolite_repo}"
    end

    banner 'Installing Gitolite'
    run "#{GIT_HOME}/gitolite/install -ln /usr/local/bin"

    id_rsa = '/tmp/id_rsa.pub'
    fatal "#{id_rsa} not found, please add it to config/teleport/files/tmp and run teleport again." unless File.exists? id_rsa

    banner 'Setting Up Gitolite'
    chown id_rsa, GIT_USER
    run_as_git "gitolite setup -pk #{id_rsa}"
  else
    banner "#{gitolite_folder} already exists, skipping gitolite setup. "
  end
end

# --------------
# Helper Methods
# --------------

def run_as_git(command)
  run "sudo -u #{GIT_USER} -H #{command}"
end

def succeeds_as_git?(command)
  system("sudo -u #{GIT_USER} -H #{command} > /dev/null 2> /dev/null")
  $? == 0
end

def fails_as_git?(command)
  !succeeds_as_git?(command)
end

setup
