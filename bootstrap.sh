#!/usr/bin/env bash

## Bootstrap script to provision a CENTOS 6 VM

source settings.conf
#export PATH="${scripts}:${PATH}"

echo '======='
echo 'PROVISIONING...'


# required stuff for barebones

echo '..Udpate yum database..'
yum -y update
echo '..Install epel and redhat-lsb-core repositories..'
#yum -y install epel-release redhat-lsb-core perl expat-devel glibc-devel gdb time git
yum -y install epel-release redhat-lsb-core time
yum clean all

echo '..Install Kerberos..'
yum -y install krb5-workstation
wget http://computing.fnal.gov/authentication/krb5conf/Linux/krb5.conf -O /etc/krb5.conf
cp /home/vagrant/slf.repo /etc/yum.repos.d/slf.repo
wget http://ftp.scientificlinux.org/linux/fermi/slf6.7/x86_64/os/RPM-GPG-KEY-sl
rpm --import RPM-GPG-KEY-sl
rm -f RPM-GPG-KEY-sl
yum install -y krb5-fermi-getcert --enablerepo=slf
yum install -y cigetcert --enablerepo=slf-security 
yum clean all


echo '..Install CVMFS..'
yum -y install yum-plugin-priorities
rpm -Uvh https://repo.opensciencegrid.org/osg/3.3/osg-3.3-el6-release-latest.rpm
yum -y install osg-oasis
yum install -y osg-wn-client

echo "user_allow_other" > /etc/fuse.conf
grep -q -F '/cvmfs' /etc/auto.master || echo "/cvmfs /etc/auto.cvmfs" >> /etc/auto.master

sudo service autofs restart

cat > /etc/cvmfs/default.local <<EOF
# Pull repositories that are in /cvmfs/*.*
CVMFS_REPOSITORIES="`echo $(ls /cvmfs | grep  '\.')|tr ' ' ,`"

# Talk directly to the stratum 1 server unless overriden in domain.d files
CVMFS_HTTP_PROXY=DIRECT
#CVMFS_HTTP_PROXY="http://squid.fnal.gov:3128"

# Expand quota (units in MB)
CVMFS_QUOTA_LIMIT=20000
CVMFS_CACHE_BASE=/var/cache/cvmfs
EOF

# Add zerofree (needed to compact VDI disk)
yum -y install zerofree
yum clean all




if [[ "${VM_TIER}" -ge 1 ]]; then
  echo "...Installing some developer tools..."
  yum -y install git make autoconf gdb strace # probably perl expat-devel glibc-devel
  # yum clean all in between these?
  yum -y install vim emacs screen
  yum -y install gcc
  yum -y install tar zip xz bzip2 patch wget which sudo
  yum -y install freetype-devel libXpm-devel libXmu-devel mesa-libGL-devel mesa-libGLU-devel libXt-devel
  yum clean all
fi


if [[ "${VM_TIER}" -ge 2 ]]; then
  yum -y groupinstall "X Window System" "Desktop"
  yum -y groupinstall fonts
  yum -y install xorg-x11-fonts-Type1
  yum clean all
fi


if [[ "${VM_TIER}" -ge 3 ]]; then
  yum -y install tigervnc-server
  yum clean all
  
  echo '..Install netdata..'
  yum -y install zlib-devel libuuid-devel libmnl-devel make autoconf \
                 autoconf-archive autogen automake pkgconfig curl jq nodejs 
  git clone https://github.com/firehol/netdata.git --depth=1 
  cd netdata
  ./netdata-installer.sh --dont-wait --dont-start-it
  echo 'art: gm2* nova* art* uboone*' >> /etc/netdata/apps_groups.conf
  cd .. 
  rm -rf ./netdata
  
  # others (though these may already be installed as dependencies...)
  #yum -y install meld valgrind ncurses-devel
  #yum -y install kernel-devel
  #yum -y install autoconf-archive autogen zlib-devel libuuid-devel libmnl-devel automake pkgconfig curl jq nodejs
  #yum -y install lsof
  
  yum clean all
fi


if [[ "${VM_TMUX}" == y ]]; then
  # Let's get tmux and friends
  wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
  tar xvf libevent-2.1.8-stable.tar.gz
  cd libevent-2.1.8-stable
  ./configure
  make
  make install
  cd ..
  rm -rf libevent* 

  wget https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz
  tar xvf tmux-2.5.tar.gz
  cd tmux-2.5
  ./configure
  make
  make install
  cd ..
  rm -rf tmux*
fi



if [[ "${VM_XROOTD_SERVER}" == y ]]; then
  yum -y install xrootd-server
  yum clean all
fi

if [[ "${VM_PNFS_SSHFS}" == y ]]; then
  # Get sshfs
  yum -y install fuse-sshfs
  mkdir /pnfs
  chown vagrant /pnfs
  chgrp vagrant /pnfs
  yum clean all
fi



echo -e '...PROVISIONING COMPLETE\n\n\n\n\n'



