#exec /usr/bin/bash --login
set -e
# Libtool
tar -xvf libtool-2.5.4.tar.xz
cd libtool-2.5.4
./configure --prefix=/usr
make && make install
rm -fv /usr/lib/libltdl.a
cd ..
sync
rm -rf libtool-2.5.4

# GDBM
tar -xvf gdbm-1.26.tar.gz
cd gdbm-1.26
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make && make install
cd ..
sync
rm -rf gdbm-1.26

# Gperf
tar -xvf gperf-3.3.tar.gz
cd gperf-3.3
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
make && make install
cd ..
sync
rm -rf gperf-3.3

# Expat
tar -xvf expat-2.7.4.tar.xz
cd expat-2.7.4
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.4
make && make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.4
cd ..
sync
rm -rf expat-2.7.4

# Inetutils
tar -xvf inetutils-2.7.tar.gz
cd inetutils-2.7
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make && make install
mv -v /usr/{,s}bin/ifconfig
cd ..
sync
rm -rf inetutils-2.7

# Less
tar -xvf less-692.tar.gz
cd less-692
./configure --prefix=/usr --sysconfdir=/etc
make && make install
cd ..
sync
rm -rf less-692

# Perl
tar -xvf perl-5.42.0.tar.xz
cd perl-5.42.0
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.42/core_perl      \
             -D archlib=/usr/lib/perl5/5.42/core_perl      \
             -D sitelib=/usr/lib/perl5/5.42/site_perl      \
             -D sitearch=/usr/lib/perl5/5.42/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads
make && make install
unset BUILD_ZLIB BUILD_BZIP2
cd ..
sync
rm -rf perl-5.42.0

# XML Parser
tar -xvf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47
perl Makefile.PL
make && make install
cd ..
sync
rm -rf XML-Parser-2.47

# Intltool
# ^ skipping on VM till we get wget
tar -xvf intltool-0.51.0.tar.gz
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make && make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd ..
sync
rm -rf intltool-0.51.0

# Autoconf
tar -xvf autoconf-2.72.tar.xz
cd autoconf-2.72
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf autoconf-2.72

# Automake
tar -xvf automake-1.18.1.tar.xz
cd automake-1.18.1
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
make && make install
cd ..
sync
rm -rf automake-1.18.1

# OpenSSL
tar -xvf openssl-3.6.1.tar.gz
cd openssl-3.6.1
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.6.1
cp -vfr doc/* /usr/share/doc/openssl-3.6.1
cd ..
sync
rm -rf openssl-3.6.1

# Libelf from Elfutils
tar -xvf elfutils-0.194.tar.bz2
cd elfutils-0.194
./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy
make -C lib && make -C libelf
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
cd ..
sync
rm -rf elfutils-0.194

# Libffi
tar -xvf libffi-3.5.2.tar.gz
cd libffi-3.5.2
./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native
make && make install
cd ..
sync
rm -rf libffi-3.5.2

# Sqlite
tar -xvf sqlite-autoconf-3510200.tar.gz
cd sqlite-autoconf-3510200
tar -xf ../sqlite-doc-3510200.tar.xz
./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -D SQLITE_SECURE_DELETE=1"
make LDFLAGS.rpath="" && make install
install -v -m755 -d /usr/share/doc/sqlite-3.51.2
cp -v -R sqlite-doc-3510200/* /usr/share/doc/sqlite-3.51.2
cd ..
sync
# not removing, make install put symlink

# Python
tar -xvf Python-3.14.3.tar.xz
cd Python-3.14.3
./configure --prefix=/usr          \
            --enable-shared        \
            --with-system-expat    \
            --enable-optimizations \
            --without-static-libpython
make && make install
cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
install -v -dm755 /usr/share/doc/python-3.14.3/html
tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.14.3/html \
    -xvf ../python-3.14.3-docs-html.tar.bz2
cd ..
sync
rm -rf Python-3.14.3

# Flit-Core
tar -xvf flit_core-3.12.0.tar.gz
cd flit_core-3.12.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist flit_core
cd ..
sync
rm -rf flit_core-3.12.0

# Packaging
tar -xvf packaging-26.0.tar.gz
cd packaging-26.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist packaging
cd ..
sync
rm -rf packaging-26.0

# Wheel
tar -xvf wheel-0.46.3.tar.gz
cd wheel-0.46.3
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist wheel
cd ..
sync
rm -rf wheel-0.46.3

# Setuptools
tar -xvf setuptools-82.0.0.tar.gz
cd setuptools-82.0.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools
cd ..
sync
rm -rf setuptools-82.0.0

# Ninja
tar -xvf ninja-1.13.2.tar.gz
cd ninja-1.13.2
export NINJAJOBS=4
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap --verbose
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
cd ..
sync
rm -rf ninja-1.13.2

# Meson
tar -xvf meson-1.10.1.tar.gz
cd meson-1.10.1
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
cd ..
sync
rm -rf meson-1.10.1

# Kmod
tar -xvf kmod-34.2.tar.xz
cd kmod-34.2
mkdir -p build
cd       build
meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false
ninja && ninja install
cd ../..
sync
rm -rf kmod-34.2

# Coreutils
tar -xvf coreutils-9.10.tar.xz
cd coreutils-9.10
patch -Np1 -i ../coreutils-9.10-i18n-1.patch
autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr
make && make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
cd ..
sync
rm -rf coreutils-9.10

# Diffutils
tar -xvf diffutils-3.12.tar.xz
cd diffutils-3.12
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf diffutils-3.12

# Gawk
tar -xvf gawk-5.3.2.tar.xz
cd gawk-5.3.2
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
rm -f /usr/bin/gawk-5.3.2
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2
cd ..
sync
# not removing, symlink

# Findutils
tar -xvf findutils-4.10.0.tar.xz
cd findutils-4.10.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make && make install
cd ..
sync
rm -rf findutils-4.10.0

# Groff
tar -xvf groff-1.23.0.tar.gz
cd groff-1.23.0
PAGE=letter ./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf groff-1.23.0

# GRUB!
tar -xvf grub-2.14.tar.xz
cd grub-2.14
unset {C,CPP,CXX,LD}FLAGS
sed 's/--image-base/--nonexist-linker-option/' -i configure
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror
make && make install
cd ..
sync
rm -rf grub-2.14

# Gzip
tar -xvf gzip-1.14.tar.xz
cd gzip-1.14
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf gzip-1.14

# IPRoute2
tar -xvf iproute2-6.18.0.tar.xz
cd iproute2-6.18.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns && make SBINDIR=/usr/sbin install
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.18.0
cd ..
sync
rm -rf iproute2-6.18.0

# Kbd
tar -xvf kbd-2.9.0.tar.xz
cd kbd-2.9.0
patch -Np1 -i ../kbd-2.9.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make && make install
cp -R -v docs/doc -T /usr/share/doc/kbd-2.9.0
cd ..
sync
rm -rf kbd-2.9.0

# Libpipeline
tar -xvf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf libpipeline-1.5.8

# Make
tar -xvf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf make-4.4.1

# Patch
tar -xvf patch-2.8.tar.xz
cd patch-2.8
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf patch-2.8

# Tar
tar -xvf tar-1.35.tar.xz
cd tar-1.35
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make && make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35
cd ..
sync
rm -rf tar-1.35

# Texinfo
tar -xvf texinfo-7.2.tar.xz
cd texinfo-7.2
sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm
./configure --prefix=/usr
make && make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd
cd ..
sync
rm -rf texinfo-7.2

# Vim
tar -xvf vim-9.2.0078.tar.gz
cd vim-9.2.0078
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make && make install
ln -sv ../vim/vim92/doc /usr/share/doc/vim-9.2.0078
cd ..
sync
rm -rf vim-9.2.0078
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

# MarkupSafe
tar -xvf markupsafe-3.0.3.tar.gz
cd markupsafe-3.0.3
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Markupsafe
cd ..
sync
rm -rf markupsafe-3.0.3

# Jinja
tar -xvf jinja2-3.1.6.tar.gz
cd jinja2-3.1.6
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Jinja2
cd ..
sync
rm -rf jinja2-3.1.6

# Systemd
tar -xvf systemd-259.1.tar.gz
cd systemd-259.1
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in
mkdir -p build
cd       build

meson setup ..                \
      --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/systemd-259.1
ninja && ninja install
tar -xf ../../systemd-man-pages-259.1.tar.xz \
    --no-same-owner --strip-components=1     \
    -C /usr/share/man
systemd-machine-id-setup
systemctl preset-all
cd ../..
sync
rm -rf systemd-259.1

# D-Bus
tar -xvf dbus-1.16.2.tar.xz
cd dbus-1.16.2
mkdir build
cd    build
meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
ninja && ninja install
ln -sfv /etc/machine-id /var/lib/dbus
cd ../..
sync
rm -rf dbus-1.16.2

# Man-DB
tar -xvf man-db-2.13.1.tar.xz
cd man-db-2.13.1
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap
make && make install
cd ..
sync
rm -rf man-db-2.13.1

# Procps-ng
tar -xvf procps-ng-4.0.6.tar.xz
cd procps-ng-4.0.6
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.6 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
            --with-systemd
make && make install
cd ..
sync
rm -rf procps-ng-4.0.6

# Util-linux
tar -xvf util-linux-2.41.3.tar.xz
cd util-linux-2.41.3
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3
make && make install
cd ..
sync
rm -rf util-linux-2.41.3

# E2fsprogs
tar -xvf e2fsprogs-1.47.3.tar.gz
cd e2fsprogs-1.47.3
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck
make && make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
cd ../..
sync
rm -rf e2fsprogs-1.47.3

# STRIPPING!
#save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
#             libc.so.6
#             libthread_db.so.1
#             libquadmath.so.0.0.0
#             libstdc++.so.6.0.34
#             libitm.so.1.0.0
#             libatomic.so.1.2.0"
#
#cd /usr/lib
#
#for LIB in $save_usrlib; do
#    objcopy --only-keep-debug --compress-debug-sections=zstd $LIB $LIB.dbg
#    cp $LIB /tmp/$LIB
#    strip --strip-debug /tmp/$LIB
#    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
#    install -vm755 /tmp/$LIB /usr/lib
#    rm /tmp/$LIB
#done
#
#online_usrbin="bash find strip"
#online_usrlib="libbfd-2.46.0.20260210.so
#               libsframe.so.3.0.0
#               libhistory.so.8.3
#               libncursesw.so.6.6
#               libm.so.6
#               libreadline.so.8.3
#               libz.so.1.3.2
#               libzstd.so.1.5.7
#               $(cd /usr/lib; find libnss*.so* -type f)"
#
#for BIN in $online_usrbin; do
#    cp /usr/bin/$BIN /tmp/$BIN
#    strip --strip-debug /tmp/$BIN
#    install -vm755 /tmp/$BIN /usr/bin
#    rm /tmp/$BIN
#done
#
#for LIB in $online_usrlib; do
#    cp /usr/lib/$LIB /tmp/$LIB
#    strip --strip-debug /tmp/$LIB
#    install -vm755 /tmp/$LIB /usr/lib
#    rm /tmp/$LIB
#done
#
#for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
#         $(find /usr/lib -type f -name \*.a)                 \
#         $(find /usr/{bin,sbin,libexec} -type f); do
#    case "$online_usrbin $online_usrlib $save_usrlib" in
#        *$(basename $i)* )
#            ;;
#        * ) strip --strip-debug $i
#            ;;
#    esac
#done
#
#unset BIN LIB save_usrlib online_usrbin online_usrlib
#rm -rf /tmp/{*,.*}


find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester

# Chapter 9:
# disable if using NM later:
# systemctl disable systemd-networkd-wait-online
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 1.1.1.1
nameserver 8.8.8.8

# End /etc/resolv.conf
EOF
echo "GusOS" > /etc/hostname
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

::1       ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF

# TODO AFTER BOOTING (AFTER CHROOT): timedatectl (hwclock shows 3 hrs ahead, not local time), localectl (do i even need to configure fonts)

# /etc/locale.conf
cat > /etc/locale.conf << "EOF"
LANG=en_US.UTF-8
EOF

# /etc/profile stuff (maybe optional):
cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf

  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi

# End /etc/profile
EOF

# /etc/inputrc
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

# /etc/shells
cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

# limit coredump space usage:
mkdir -pv /etc/systemd/coredump.conf.d

cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
[Coredump]
MaxUse=1G
EOF

# Chapter 10: Making the LFS System Bootable
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda2       /           ext4     defaults            1     1

# End /etc/fstab
EOF

# Compiling the Kernel
cd /sources
tar -xvf linux-6.18.10.tar.xz
cd linux-6.18.10
make mrproper
make defconfig
# ^ sets up .config w/ defaults by hardware (?)
scripts/config \
  --disable WERROR \
  --enable PSI \
  --disable PSI_DEFAULT_DISABLED \
  --disable IKHEADERS \
  --enable CGROUPS \
  --enable MEMCG \
  --enable CGROUP_SCHED \
  --disable RT_GROUP_SCHED \
  --disable EXPERT \
  --enable RELOCATABLE \
  --enable RANDOMIZE_BASE \
  --enable STACKPROTECTOR \
  --enable STACKPROTECTOR_STRONG \
  --enable NET \
  --enable INET \
  --enable IPV6 \
  --disable UEVENT_HELPER \
  --enable DEVTMPFS \
  --enable DEVTMPFS_MOUNT \
  --enable FW_LOADER \
  --disable FW_LOADER_USER_HELPER \
  --enable DMIID \
  --enable SYSFB_SIMPLEFB \
  --enable DRM \
  --enable DRM_PANIC \
  --enable DRM_FBDEV_EMULATION \
  --enable DRM_SIMPLEDRM \
  --enable FRAMEBUFFER_CONSOLE \
  --enable INOTIFY_USER \
  --enable TMPFS \
  --enable TMPFS_POSIX_ACL \
  --enable X86_X2APIC \
  --enable PCI \
  --enable PCI_MSI \
  --enable IOMMU_SUPPORT \
  --enable IRQ_REMAP \
  --enable BLK_DEV_NVME
make olddefconfig
# ^ sets up defaults for unset config variables
make && make modules_install
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.18.10-lfs-13.0-systemd
cp -iv System.map /boot/System.map-6.18.10
cp -iv .config /boot/config-6.18.10
cp -r Documentation -T /usr/share/doc/linux-6.18.10

# GRUB
grub-install /dev/sda --target i386-pc

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd0,gpt2)
set gfxpayload=1024x768x32

menuentry "GNU/Linux, Linux 6.18.10-lfs-13.0-systemd" {
        linux   /boot/vmlinuz-6.18.10-lfs-13.0-systemd root=/dev/sda2 ro
}
EOF

# Final touches
echo 13.0-systemd > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="13.0-systemd"
DISTRIB_CODENAME="GusOS"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="13.0-systemd"
ID=lfs
PRETTY_NAME="Linux From Scratch 13.0-systemd"
VERSION_CODENAME="GusOS"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
RELEASE_TYPE="stable"
EOF

