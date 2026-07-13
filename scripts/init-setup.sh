#!/bin/bash

set -e
# Make sda1 into a bootable partition:
sudo gdisk /dev/sda << EOF
t
1
ef02
w
y
EOF

# Downloading packages:
#wget https://www.linuxfromscratch.org/lfs/downloads/stable-systemd/wget-list
#wget https://www.linuxfromscratch.org/lfs/downloads/stable-systemd/md5sums
#wget http://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz
#wget -i wget-list

# Verify integrity
pushd $LFS/sources
md5sum -c md5sums
popd

chown root:root $LFS/sources/*

# Chapter 4
# Setting up build directories
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

mkdir -pv $LFS/lib64
mkdir -pv $LFS/tools

# Making lfs user so we don't build as root
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo -e "lfs\nlfs" | passwd lfs
chown -v lfs $LFS/{usr{,/*},var,etc,tools}
chown -v lfs $LFS/lib64

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE

sudo ln -sv /usr/bin/gcc-14 /usr/bin/gcc
sudo ln -sv /usr/bin/g++-14 /usr/bin/g++
