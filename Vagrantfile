# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  # The main OS box
  config.vm.box = "bento/centos-6.8"

  # Create a private network, needed for nfs
  config.vm.network "private_network", type: "dhcp"

  # Forward this port for monitoring
  config.vm.network "forwarded_port", guest: 19999, host: 19999, host_ip: "127.0.0.1", auto_correct: true, id: "netdata"
  config.vm.network "forwarded_port", guest: 5901,  host: 5901, host_ip: "127.0.0.1", auto_correct: true, id: "vnc"
  config.vm.network "forwarded_port", guest: 6901,  host: 6901, host_ip: "127.0.0.1", auto_correct: true, id: "novnc"

  # For speed, we mount /Users with nfs
  config.vm.synced_folder "/Users", "/Users" , type: "nfs", map_uid: 502, map_gid: 20,  bsd__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']


  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.cpus = 4
    vb.memory = 1024 * 4 * 2  # Memory is 2 GB per CPU

    vb.customize ["modifyvm", :id, "--vram", "128", "--accelerate3d", "on", "--accelerate2dvideo", "on"]
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
    vb.customize [ "setextradata", :id, "VBoxInternal2/SavestateOnBatteryLow", 0 ]
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "file", source: "./slf.repo", destination: "slf.repo"
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vbguest.auto_update = true
  config.vbguest.no_remote = true
end
