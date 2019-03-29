Vagrant.configure("2") do |config|
  
  # The main OS box
  config.vm.box = "bento/centos-6.8"
  
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = 1024 * 3
  end
  
  # original:
  #config.vm.synced_folder "/Users", "/Users" , type: "nfs", map_uid: 502, map_gid: 20,  bsd__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']
  #config.vm.synced_folder "var_run", "/var/run"
  #config.vm.synced_folder "tmp", "/tmp"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  # prevent updating guest additions
  config.vbguest.auto_update = false
  
  # copy SLF repository information
  config.vm.provision "file", source: "./files/slf.repo", destination: "slf.repo"
  
  # copy FNAL Kerberos config
  config.vm.provision "file", source: "./files/krb5-fnal.conf", destination: "krb5-fnal.conf"
  
  # copy RPM GPG ckey
  config.vm.provision "file", source: "./files/RPM-GPG-KEY-sl", destination: "RPM-GPG-KEY-sl"
  
  # copy CVMFS setup file
  config.vm.provision "file", source: "./files/cvmfs_default.local", destination: "cvmfs_default.local"
  
  # copy pip install script
  config.vm.provision "file", source: "./files/get-pip.py", destination: "get-pip.py"
  
  # bootstrap script (install & configure stuff like CVMFS, etc)
  config.vm.provision "shell", path: "./files/bootstrap.sh"
  
  
end
