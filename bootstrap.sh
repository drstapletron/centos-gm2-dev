#!/usr/bin/env bash

## Bootstrap script to provision a CENTOS 6 VM

echo '======='
echo 'PROVISIONING...'

echo '..Udpate yum database..'
yum -y update
yum clean all

echo '..Install epel and redhat-lsb-core repositories..'
yum -y install epel-release redhat-lsb-core perl expat-devel glibc-devel gdb time git
yum clean all

echo '..Install some developer tools..'
yum -y install emacs screen gcc gdb meld valgrind ncurses-devel
yum clean all
yum -y install openssl-devel tar zip xz bzip2 patch wget which sudo strace
yum clean all
yum -y install kernel-devel
yum clean all
yum -y install freetype-devel libXpm-devel libXmu-devel mesa-libGL-devel mesa-libGLU-devel libXt-devel
yum clean all
yum -y groupinstall "X Window System" "Desktop"
yum -y groupinstall fonts
yum -y install tigervnc-server xorg-x11-fonts-Type1

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

echo '..Install netdata..'
yum -y install zlib-devel libuuid-devel libmnl-devel gcc make git autoconf \
               autoconf-archive autogen automake pkgconfig curl jq nodejs 
git clone https://github.com/firehol/netdata.git --depth=1 
cd netdata
./netdata-installer.sh --dont-wait --dont-start-it
echo 'art: gm2* nova* art* uboone*' >> /etc/netdata/apps_groups.conf
cd .. 
rm -rf ./netdata

echo '..Install CVMFS..'
yum -y install yum-plugin-priorities
rpm -Uvh https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm
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

yum install -y lsof xrootd-server

# Add zerofree (needed to compact VDI disk)
yum -y install zerofree
yum clean all

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

# Get sshfs
yum -y install fuse-sshfs
mkdir /pnfs
chown vagrant /pnfs
chgrp vagrant /pnfs

yum clean all

echo '...PROVISIONING COMPLETE'
