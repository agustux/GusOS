#!/bin/bash

# Copy Ventoy LFS files into $LFS/sources:
mkdir -pv /mnt/ventoy
# ls -l /dev/mapper/
mount /dev/dm-1 /mnt/ventoy
pacman-key --init
pacman-key --populate archlinux
pacman -U /mnt/ventoy/GusOS/arch-packages/*.zst

# Generate key to verify the packages we'll need later:
# Set up partitions
fdisk /dev/sda
mkfs.ext4 /dev/sda2

export LFS=/mnt/lfs
umask 022

# Mount it
mkdir -pv $LFS
mount /dev/sda2 $LFS

# Set permissions for writing
chown root:root $LFS
chmod 755 $LFS

############################# DONE WITH FILESYSTEM STUFF

# Make directory for building on $LFS
mkdir -v $LFS/sources
# Add sticky permissions, so only owner can actually delete stuff:
chmod -v a+wt $LFS/sources # NOTE: nvm, probably a specific change against the chmod 755 we just did

cp -r /mnt/ventoy/GusOS/src/* $LFS/sources
cp -r /mnt/ventoy/GusOS/scripts/* $LFS/sources

cd $LFS/sources
