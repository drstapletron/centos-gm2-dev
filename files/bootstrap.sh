#!/usr/bin/env bash


################################################################
function die() {
  retval=$?
  {
    echo
    echo "> ERROR!"
    echo ">        file: ${BASH_SOURCE[0]}:${BASH_LINENO[0]}"
    echo -n ">  call stack: "
    for ((i=0;i<${#BASH_SOURCE[@]};++i))
    do echo -n "${BASH_SOURCE[i]}:${BASH_LINENO[i]}  "
    done; echo
    echo ">      status: ${retval}"
    echo ">     message: ${@}"
    echo
  } 1>&2
  exit $retval
}
################################################################

echo "BOOTSTRAP"

# set osg_cvmfs=fnal_krb=getcert=graphics=n
# 944Mb used disk space, can source gm2 v9_04 but CANNOT run artg4
# also cannot get a Kerberos certificate (nor log into gm2gpvmNN)

# set graphics=y and it uses ~1040Mb

osg_cvmfs=n
fnal_krb=n
getcert=n
graphics=y
setup_pip=y
setup_heist=y

#yum -y update

yum install -y redhat-lsb-core || dia "Failed to install redhat-lsb-core"

# epel-release is required for osg-wn-client
if [[ "${osg_cvmfs}" == y ]]
then yum -y install epel-release || die "Failed to install package repository add-ons"
fi

if [[ "${graphics}" == y ]]
then {
  # I think mesa-libGL is already installed...
  # some of these things probably already come in with mesa-libGL-devel
  # I still have a problem with libglapi and/or libgles
  # anyway, artg4 won't run without the following:
  yum -y install mesa-libGL mesa-libGLU libSM libX11 libXext libXmu mesa-libGL-devel mesa-dri-drivers
  
  # I suspect I need this whether or not I get root working (e.g. matplotlib)
  yum -y install libpng libXcursor
  
  ## root won't work without these
  #yum -y install libXpm libXft
  ## and X11 forwarding still doesn't work without this
  #yum -y install xorg-x11-auth
  ## and maybe this
  #yum -y install xorg-x11-utils xorg-x11-server-utils
  ## and these are just a guess to fix the `waidpid() from libc` segfault
  #yum -y install glibc-devel compat-glibc libstdc++-devel compat-libstdc++
  #yum -y install libjpeg-turbo libpng libtiff libXcursor
  
  # this is CONFIRMED TO WORK
  yum -y install libXpm libXft xorg-x11-auth xorg-x11-utils xorg-x11-server-utils glibc-devel compat-glibc libstdc++-devel compat-libstdc++ libjpeg-turbo libpng libtiff libXcursor expat-devel
  yum -y groupinstall 'X Window System'
  yum -y install xterm
  yum -y install openssl-devel
}
fi

# kerberos is mandatory?
if [[ "${fnal_krb}" == y ]]
then {
  yum -y install krb5-workstation || die "Install krb5-workstation failed"
  cp krb5-fnal.conf /etc/krb5.conf || die "Copy FNAL kerb5.conf failed"
}
fi

# getcert
if [[ "${getcert}" == y ]]
then {
  cp slf.repo /etc/yum.repos.d/ || die "Copy slf.repo failed"
  rpm --import RPM-GPG-KEY-sl || die "Failed to import RPM GPG KEY"
  yum install -y krb5-fermi-getcert --enablerepo=slf || die "Install krb5-fermi-getcert failed"
  yum install -y cigetcert --enablerepo=slf-security || die "Install cigetcert failed"
}
fi


# CVMFS
if [[ "${osg_cvmfs}" == y ]]
then {
  yum -y install yum-plugin-priorities || die "Install yum-plugin-priorities failed"
  rpm -Uvh https://repo.opensciencegrid.org/osg/3.3/osg-3.3-el6-release-latest.rpm \
    || die "Failed to install osg 3.3 RPM package"
  yum -y install osg-oasis || die "Install osg-oasis failed"

  # it looks like I need osg-wn-client, but it has like 190 dependencies
  # (check yum deplist osg-wn-client)
  #yum -y install epel-release || die "Install epel-release failed"
  yum -y install osg-wn-client || die "Install osg-wn-client failed"
  # so maybe I can install it *without* dependencies, and include whatever packages
  # EDIT: maybe I don't even need osg-wn-client itself - maybe I need one of its deps?
  #yum -y install osg-version autofs
  #yum -y install epel-release
  #yum -y install --nodeps osg-wn-client
}
else {
  ##cvmfs_rpm="https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm"
  #cvmfs_rpm="http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs/EL/6/x86_64/cvmfs-2.4.4-1.el6.x86_64.rpm"
  ##cvmfs_rpm="http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs/x86_64/cvmfs-2.4.4-1.el5.x86_64.rpm"
  ##cvmfs_rpm="http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs/x86_64/cvmfs-2.5.0-1.el5.x86_64.rpm"
  yum -y install "http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs/EL/6/x86_64/cvmfs-config-default-1.4-1.noarch.rpm" || die "Failed to install CVMFS config package"
  yum -y install "http://cvmrepo.web.cern.ch/cvmrepo/yum/cvmfs/EL/6/x86_64/cvmfs-2.4.4-1.el6.x86_64.rpm" || die "Failed to install CVMFS package"
}
fi

echo "user_allow_other" >> /etc/fuse.conf || die "Failed to set FUSE configuration"

# NOTE: have to install autofs to get /etc/auto.master
{
  grep -q -F '/cvmfs' /etc/auto.master \
    || echo "/cvmfs /etc/auto.cvmfs" >> /etc/auto.master
} || die "Failed to set CVMFS config in autofs"

service autofs restart || die "Failed to restart autofs service"

cp cvmfs_default.local /etc/cvmfs/default.local \
  || die "Failed to setup /etc/cvmfs/default.local"

yum clean all


echo -e "\n\nAttempting to access CVMFS filesystem..."
echo "ls /cvmfs/gm2.opensciencegrid.org/..."
ls /cvmfs/gm2.opensciencegrid.org \
  || die "Could not browse gm2.opensciencegrid.org through CVMFS"



if [[ "${setup_pip}" == y ]]
then {
  PIP_ROOT=/installs/pip/root
  mkdir -p "${PIP_ROOT}" || die "Failed to create ${PIP_ROOT}"
  [[ -f "get-pip.py" ]] || die "Missing script get-pip.py"
  source /cvmfs/gm2.opensciencegrid.org/prod/g-2/setup || die "Failed to source gm2 setup from CVMFS"
  setup gm2 "${GM2_VERSION_LATEST}" -q prof || die "Failed to setup gm2 ${GM2_VERSION_LATEST}"
  #python get-pip.py --user --root "${PIP_ROOT%root}" || die "Failed to install pip with custom root"
  
  # maybe something like this:
  # pip --no-cache-dir --disable-pip-version-check --log piplog.txt -v -v install --no-compile --prefix /installs/pip numpy scipy matplotlib pandas
  # chown -R vagrant:vagrant /installs/pip
  
  cat >> "${PIP_ROOT%/root}/setup_pip" <<EOF
export PIP_ROOT="${PIP_ROOT}"

export PATH="${PIP_ROOT}/${HOME}/.local/bin:\${PATH}"
export PATH="${PIP_ROOT}/${PYTHON_LIB%/lib}/bin:\${PATH}"

export PYTHONPATH="${PIP_ROOT}/${HOME}/.local/lib/python2.7/site-packages:\${PYTHONPATH}"
export PYTHONPATH="${PIP_ROOT}/${PYTHON_LIB}/python2.7/site-packages:\${PYTHONPATH}"
EOF
}
fi



if [[ "${setup_heist}" == y ]]
then {
  HEIST_DIR=/installs/heist
  mkdir -p "${HEIST_DIR}" || die "Failed to create ${HEIST_DIR}"
  cd "${HEIST_DIR}" || die "Failed to cd to ${HEIST_DIR}"
  git clone https://github.com/drstapletron/heist.git || die "Failed to clone heist repository"
  
  cat >> "${HEIST_DIR}/setup_heist" <<EOF
export HEIST_DIR="${HEIST_DIR}"
export PYTHONPATH="${HEIST_DIR}:\${PYTHONPATH}"
EOF
}
fi


cat <<EOF

Don't forget to do the following!
  export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:/lib64:/lib:/usr/lib64:/usr/lib"
  export ROOT_INCLUDE_PATH="\${EIGEN_INC}:\${GEANT4_FQ_DIR}/include:\${ROOT_INCLUDE_PATH}"

EOF


