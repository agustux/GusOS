# manual.sh
# follow instructions

# init-setup.sh:
./init-setup.sh

#lfs-building-pt1.sh: 
./lfs-building-pt1.sh

#lfs-building-pt2.sh: 
./lfs-building-pt2.sh

#root-building.sh: 
./root-building.sh 

#chroot-building-pt1.sh: 
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login
cd $LFS/sources
./chroot-building-pt1.sh 

#chroot-building-pt2.sh:
exec /usr/bin/bash --login
./chroot-building-pt2.sh

#chroot-building-pt3.sh:
exec /usr/bin/bash --login
./chroot-building-pt3.sh

#clean-up.sh:
logout
./clean-up.sh
