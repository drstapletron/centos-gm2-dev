# centos-gm2-dev


This repository has a Vagrantfile and auxillary files for building a Centos 6.8 (equivalent to SLF6) Virtual Machine suitable for development of Muon g-2 offline code. 

The idea is to have a virtual machine with a run-time environment similar to that of grid jobs along with a development environment. See below for some workflow ideas.

Forked September 2017 to

  * use vagrant to build multiple 'tiers' of our development environment (optionally including graphical environment, profilers, or other things)
  * create disk images that the Muon g-2 users can just download and plug into VirtualBox
  * improve compatibility with Linux and Windows
  * include facility to set up pip (in a shared folder on the host)
  * gallery and heist
  * an example file (or a README or something) in the home folder?
  * update krb5.conf link and some other minor things


## 1 Terminology

The "host" is your metal machine (e.g. your laptop) running your host OS (e.g. MacOS). The `guest` is the virtual machine (VM) running SLF6. 
`VirtualBox` is a free product from Oracle that allows you to run Virtual Machines. `Vagrant` is a configuration manager that makes setting up and configuring VMs in VirtualBox easier. 

## 2 Features

Installed with this VM are:

* CVMFS
* emacs editor
* GNU screen
* X-windows (you can pop a window to your ssh host)
* VNC server
* Mesa OpenGL
* gdb
* git
* meld (graphical diff)
* valgrind
* kerberos
* netdata (for monitoring resource usage of the VM)

The VM configuration assumes you have a Mac as the host as it shares your `/Users` directory with the VM. It ought to work fine on Windows too, but you will need to alter the `Vagrantfile` and change the folder sharing (should be obvious). 

## 3 Main Installation

Note that the installation requires a large amount of downloads. Be sure to have a fast internet connection. 

- Download and install VirtualBox from http://www.virtualbox.org/
- Download and install Vagrant (flavor appropriate for your **host**) from https://www.vagrantup.com/downloads.html

Install the `vagrant-guest` plugin (keeps the VirtualBox Guest Additions up to date on the VM -- you need this to access your host disk). From your terminal...
```bash
vagrant plugin install vagrant-vbguest
```

Clone or download this repository
```
git clone https://github.com/lyon-fnal/centos-gm2-dev.git
cd centos-gm2-dev
```

Check the `Vagrantfile` by editing it in your favorite editor. In particular, look for the lines,

```
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.cpus = 4
    vb.memory = 1024 * 4 * 2
```
and set the number of CPUs and memory size (in units of megabytes) according to your host machine. I give the VM half of my laptop's CPUs. I like 2 GB per CPU, but if you don't have much memory on your host, then you could do with 1 GB per CPU. You probably shouldn't allocate more than half of your host's total memory. 

### 3.1 Provision the VM

Provisioning means to install and configure stuff in the VM to make it usable for what you want to do. 

Be sure you are in the directory with the `VagrantFile`. 

Bring up the VM with full provisioning (it may take many minutes to run)
```
vagrant up
```

Note that you may need to give your host machine's administrative password because NFS needs to be set up for file sharing. 

You may see an error like,
```
No guest IP was given to the Vagrant core NFS helper. This is an
internal error that should be reported as a bug.
```
Just issue `vagrant up` again. That error happens when the VM starts up before NFS was configured. 

You may also see an error like,
```
An error occurred while downloading the remote file. The error
message, if any, is reproduced below. Please fix this error and try
again.

The requested URL returned error: 404 Not Found
```

If you see that, do
```
cat ~/.vagrant.d/boxes/box-cutter-VAGRANTSLASH-centos68/metadata_url
```

it should EXACTLY match

```
https://vagrantcloud.com/box-cutter/centos68
```

If it doesn't match, then fix the file. Note that the file must **not** end with a new line or spurious spaces. Then issue `vagrant up` again. 

If things are working, it may take a long time to populate the VM with all of the software. 

When it finishes, the virtual machine is now ready. Do `vagrant ssh` to log in.

## 4 Interacting with the VM

To interact with your VM, you need to be in the directory that has the `VagrantFile` file mentioned above. The `vagrant` commands know what VM you mean by the directory you are in. 

### 4.1 Starting and entering the VM

If you have recently rebootted your machine, it is likely that your VM is not running. You can always check with 

```bash
vagrant status
```

If it doesn't say `running`, then issue 

```bash
vagrant up
```

Note that you may need to give your host machine's administrative password because NFS needs to be set up for file sharing. 

You can then `ssh` into the VM with,

```bash
vagrant ssh
```

If for some reason you want to reboot the VM, you can do that with

```bash
vagrant reload
```

You can stop the virtual machine with 

```bash
vagrant halt
```


### 4.2 Things you can do in the VM

There are many things you can do in the SLF6 Virtual Machine

#### 4.2.1 CVMFS

CVMFS is automounted. That means that when you first log into a fresh VM, doing `ls /cvmfs` will look empty. That's ok. You need to access a sub-directory first. Simply accessing `/cvmfs/gm2.opensciencegrid.org` in any way (`ls` or `source` a script inside) will mount the volume. You can mount any other CVMFS volume like `/cvmfs/fermilab.opensciencegrid.org` as well. 

An easy way to start is 

```
source /cvmfs/gm2.opensciencegrid.org/prod/g-2/setup 
```

Unfortunately, tab completion for the directory name only works when it is mounted. So you will not have tab completion for the first access.

Note that accessing files for the first time in `/cvmfs/...` may be slow because the files need to be downloaded. 

#### 4.2.2 X-windows

You can pop X-windows programs, like Root, in the VM and have them show up on your host, so long as you have an X-windows client like XQuartz for the Mac. For that to work, you will need to ssh into the VM with X-windows forwarding turned on. 

```
vagrant ssh -- -Y
```

You should be able to pop X-window programs on your host. Note that, however, X-windows tends to be quite slow. 

#### 4.2.3 VNC

A VNC server is a much faster way to interact with the VM as compared to X-windows. A VNC server is included in the VM. Here's how to run it. 

The first thing you should do is to create a password for your VNC server (it can be simple, VNC will be restricted to your laptop). Do that with 

```
vncpasswd
```

You can start your vnc server with,

```
vncserver -geometry 1400x900
```

You should see output referencing to `localhost.localdomain:1`. If you see `:2` instead, that means that you now have two vnc servers running. You should remove them with 
```
vncserver -kill :1 ; vncserver -kill :2
```
and start the server again. 

Note that the VNC server will out live your ssh terminal session. You should get in the habit of killing the server when you are done with it. You can do that with `vncserver -kill :1`

You can even start the VNC server from your host directly with 

```
vagrant ssh -- vncserver -geometry 1400x900
```

Note that if you run `vncserver` on a Fermilab machine, you should **always** use the `-localhost` flag to restrict access to the VNC server. You do not need that here as VirtualBox will prevent outside access to your VNC server on the VM. 

You can access the VNC server on your host with a VNC client. A Mac comes with one already installed called "Screen Sharing.app". The connection URL is `localhost:5901`. Use the password you entered above. If you are using the "Screen Sharing.app" be sure to turn "Scaling" on (from the "View" menu). That will improve the sharpness of the GUI. 

If the VNC screen blanks out and then asks you for a password, that password will be `vagrant` .

A terminal program is available in the desktop from the menu "Applications -> System Tools -> Terminal". You can configure this desktop as you wish and your changes will be persistent between sessions. 

If you still have your ssh terminal, you can pop windows into the VNC server by first doing,

```
export DISPLAY=:1

# Then you can do,
gnome-terminal &  # Pop a terminal in the VNC
root # Run root
```

Remember to kill the VNC server when you are done your session with `vncserver -kill :1`

If you do not have a Mac, then do a Google search for VNC clients. Most should work with the server installed on the VM. 

#### 4.2.4 Accessing the host file systm

Your username on the VM is `vagrant`. The `/home/vagrant` directory is on the VM filesystem. The `/vagrant` directory in the VM is the same directory on your host that has the `VagrantFile`. 

If you are on a Mac, you should also be able to access your Mac's files with `/Users/<macUserName>`. Access to those files should be quite fast as they are served with NFS. 

For Windows, you can likely set up a similar mount. 

#### 4.2.5 Obtaining a kerberos ticket

Kerberos is installed in the VM. Be sure to give your Fermilab user name when requesting a ticket (if you don't you will get an error as the unix username in the VM is `vagrant`). 

```bash
kinit fred@FNAL.GOV
```

You will also need your Fermilab user name when you log in to the Fermilab machine...

```bash
ssh fred@gm2gpvm04.fnal.gov
```


#### 4.2.6 Accessing g-2 data

Processing large amounts of data should be performed by grid jobs. However, for testing or small analyses, you may want to transfer some files to your local machine with your VM. There are two easy ways to transfer files to your local machine. 

* `scp` allows you to directly copy files from a Fermilab node to your machine. You will need a kerberos ticket (see above). Then use the `scp` command like `cp`, but with the user and machine name included as shown below. If you use wild cards, enclose the expression in single quotes (otherwise your local VM shell will try to interpret them). 

```
scp 'fred@gm2gpvm04.fnal.gov:/gm2/app/users/fred/myStuff/*' . 
scp fred@gm2gpvm04.fnal.gov:/pnfs/GM2/scratch/users/fred/myDir/myFavoriteDataFile.root .
```

* Another way to directly work with a remote file system is to use `sshfs`, which is installed in the VM. `sshfs` allows you to mount a remote directory as if it is a file system in your VM. You can do this for files in `/pnfs` but remember that quickly accessing those files may cause a high load for dCache. sshfs has a nice feature that it caches files locally. If you have a file in `/pnfs` that you are reading from repeatedly, `sshfs` will make repeat access very fast with the caching. 

   There is a `/pnfs` mount point in the VM. You must give it correct permissions by doing,
   
   ```bash
   # Only do this once in the life of the VM
   sudo chown vagrant /pnfs ; sudo chgrp vagrant /pnfs
   ```
   
   Then you can mount `/pnfs` with...
   
    ```
    sudo kinit fred@FNAL.GOV   # Note that you must run this with `sudo` to save your ticket in the right place
    sudo sshfs fred@gm2gpvm04.fnal.gov:/pnfs /pnfs -o allow_other  
   ```
  
  You can then access files directly from your VM's `/pnfs/GM2/...`. 
  
  You can unmount the remote volume with 
  
  ```
  sudo umount /pnfs
  ```
  
  You will need to issue the `sshfs` command everytime you restart the VM. 
  
#### 4.2.7 Monitoring VM performance with netdata

The `netdata` monitoring system is installed and automatically runs in the VM. This is the same system we run in the control room to monitor the DAQ machines. On your host, open `localhost:19999` in your browser and you'll see the monitoring page. If you are running a `gm2` program, click on the "Applications" section and you'll see metrics for a group called `art`. With those metrics you can see memory, CPU, disk, and network usage for your art program execution. 
  
## 5 Workflows tips

Here are some tips for using the virtual machine.

### 5.1 Use the host file system

You should use the host file system as much as possible and avoid writing to `/home/vagrant`. 

The VM's file system lives in a file on your host machine. The more you write to the VM's file system, the larger that file becomes. It will never shrink. To avoid it becoming huge, use a directory on your host machine like `/Users/fred/Development/whatever`.  Because that is served with NFS, access should be very fast. You can put g-2 code and executables there too. 

### 5.2 You have the full g-2 development enviornment

`setup` works. `mrb` works. `gm2` works. It all works and the code you build here can used for grid jobs. 

### 5.3 Use VNC 

With VNC, you can make a nice GUI environment that is very responsive. Doing things out of your host's terminal program works too. See above for how to pop windows from there into the VNC screen. 
