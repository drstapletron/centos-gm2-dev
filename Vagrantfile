# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

VAGRANTFILE_API_VERSION = 2

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "box-cutter/centos67"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder "/Users", "/Users"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.cpus = 4
    vb.memory = 1024 * 4 * 2  # Memory is 2 GB per CPU
    vb.customize ["modifyvm", :id, "--vram", "128", "--accelerate3d", "on"]
    config.vm.network "forwarded_port", guest: 19999, host: 19999, host_ip: "127.0.0.1", auto_correct: true
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "file", source: "./toCopyToVM/bin", destination: "bin"
  config.vm.provision "file", source: "./toCopyToVM/moreInstalls", destination: "moreInstalls"
  config.vm.provision "file", source: "./toCopyToVM/slf.repo", destination: "slf.repo"
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vbguest.auto_update = true
  config.vbguest.no_remote = true
end
