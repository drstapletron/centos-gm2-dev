# centos-gm2-dev

This repository has a Vagrantfile and auxillary files for building a Centos 6.7 (equivalent to SLF6) Virtual Machine suitable for development of Muon g-2 offline code. 

The idea is to have a virtual machine with a run-time environment similar to that of Grid jobs along with a partial development environment. You could do your code editing with the included Emacs editor, or, with VirtualBox's folder sharing, use a IDE on your host system (Windows or Mac). With Eclipse on the Mac, I have been able to develop and build code within the VM. A debugger (gdb) and several profilers (see below) are included in the installation as well. 

## Features

Installed with this VM are:

* CVMFS with `/cvmfs/gm2.opensciencegrid.org` configured and ready to go
* emacs editor
* GNU screen
* Minimal X-windows (you can pop a window to your ssh host)
* Mesa OpenGL
* gdb
* git
* meld (graphical diff)
* valgrind

Also included are installers for two profilers: `igprof` and `OpenSpeedShop`

The VM configuration assumes you have a Mac as the host as it shares your `/Users` directory with the VM. It ought to work fine on Windows too, but you will need to alter the `Vagrantfile` and change the folder sharing (easy). 

## Main Installation

Note that the installation requires a large amount of downloads. Be sure to have a fast internet connection. 

Download and install VirtualBox from http://www.virtualbox.org/
Download and install Vagrant from https://www.vagrantup.com/downloads.html  -- but see below.

**NOTE** Vagrant v1.8.5 has a known bug that completely breaks Vagrant for the Mac (it will get stuck with repeating warnings `default: Warning: Authentication failure. Retrying...` ). Until v1.8.6 is out, please use the older version v1.8.4. Use this link to download: https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.dmg

Install the `vagrant-guest` plugin (keeps the VirtualBox Guest Additions up to date on the VM). From your terminal...
```
vagrant plugin install vagrant-vbguest
```

Clone or download this repository
```
git clone https://github.com/lyon-fnal/centos-gm2-dev.git
cd centos-gm2-dev
```

### Convert disk
If you would like to keep your VM disk small, you should convert it to a VDI format. This format is compactable by VirtualBox commands. The default format of VMDK is not. Here are instructions to convert (skip to "Provision the VM" if you don't want to do this). 

```
vagrant up --no-provision  # Create the bare VM
vagrant halt               # Shut it down
```

Start up your VirtualBox App (the GUI). Locate your new VM (called `centos-gm2-dev-XXXX` where `XXXX` is more stuff). Click on settings, click on storage. You may need to click on the controller to reveal the `VMDK` file. Right click on the path and select Copy. Now, in your host machine's terminal (e.g. on your Mac) cd to that directory (you may need to surround it in quotes if there are spaces in it). Now do,

```
VBoxManage clonehd --format vdi centos67-disk1.vmdk centos67-disk1.vdi   # Make sure the names match your files
```

Go back to the VirtualBox GUI and the storage panel. Right click on the VMDK file and select "Remove Attachment". Now click on the plus and add the VDI disk you just made.

You can delete the old disk with

```
VBoxManage closemedium disk centos67-disk1.vmdk --delete
```

You may now provision the VM

### Provision the VM

Provisioning means to install and configure stuff in the VM to make it usable for what you want to do. 

Bring up the VM with full provisioning (it may take many minutes to run)
```
vagrant up
```

The virtual machine is now ready. Do `vagrant ssh` to log in.

## Installing Profilers

There are two profilers that you may want to install in your VM. `igprof` is the profiler that CMS uses. See http://igprof.org/ . `OpenSpeedShop` is a profiler designed for high performance computing, but it runs well on laptops. It comes with a GUI interface. See https://openspeedshop.org/ . You can also use `valgrind` (already installed). 

Installing these packages is easy and mostly automated (but take a long time to run). `vagrant ssh` into the VM and go to the `~/moreInstalls` directory. Installing both, you would do

```
sudo ./install-igprof.sh
sudo ./install-openspeedshop.sh # Takes a VERY long time 
```

Once this is done, you may delete the `~/moreInstalls` directory. Note that these installs (especially openspeedshop) will bloat your VM disk. If you converted the disk
to VDI as per instructions above, you can compactify it by following instructions at http://superuser.com/questions/529149/how-to-compact-virtualboxs-vdi-file-size (`zerofree` is
installed, so you should use it). 



