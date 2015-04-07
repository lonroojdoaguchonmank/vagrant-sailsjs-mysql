# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "minimal/jessie64"
  config.vm.synced_folder "projects/", "/home/vagrant/projects"
  config.vm.network "forwarded_port", guest: 1337, host: 1337, protocol: "tcp"

  config.vm.provision "shell", path: "system_setup.sh"
  config.vm.provision "shell", path: "docker_setup.sh"
end
