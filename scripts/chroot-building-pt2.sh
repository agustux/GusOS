#exec /usr/bin/bash --login
set -e
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

cd /sources

# Gettext
tar -xvf gettext-1.0.tar.xz
cd gettext-1.0
./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
cd ..
sync
rm -rf gettext-1.0

# Bison 
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2
make && make install
cd ..
sync
rm -rf bison-3.8.2

# Perl
tar -xvf perl-5.42.0.tar.xz
cd perl-5.42.0
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl
make && make install
cd ..
sync
rm -rf perl-5.42.0

# Python
tar -xvf Python-3.14.3.tar.xz
cd Python-3.14.3
./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython
make && make install
cd ..
sync
rm -rf Python-3.14.3

# Texinfo
tar -xvf texinfo-7.2.tar.xz
cd texinfo-7.2
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf texinfo-7.2

# Util-linux
tar -xvf util-linux-2.41.3.tar.xz
cd util-linux-2.41.3
mkdir -pv /var/lib/hwclock
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.3
make && make install
cd ..
sync
rm -rf util-linux-2.41.3

# Clean up (7.13)
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
sync
rm -rf /tools

# Man Pages
tar -xvf man-pages-6.17.tar.xz
cd man-pages-6.17
rm -v man3/crypt*
make -R GIT=false prefix=/usr install
cd ..
sync
rm -rf man-pages-6.17

# Iana-Etc
tar -xvf iana-etc-20260202.tar.gz
cd iana-etc-20260202
cp -v services protocols /etc
cd ..
sync
rm -rf iana-etc-20260202

# Glibc
#rm -rf glibc-2.43
#tar -xvf glibc-2.43.tar.xz
cd glibc-2.43
sync
rm -rf build
#patch -Np1 -i ../glibc-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.4
make && make check || true
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

#make localedata/install-locales
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2025c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz

ln -sfv /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d
cd ../..
sync
rm -rf glibc-2.43

# Zlib
tar -xvf zlib-1.3.2.tar.gz
cd zlib-1.3.2
./configure --prefix=/usr
make && make install
rm -fv /usr/lib/libz.a
cd ..
sync
rm -rf zlib-1.3.2

# Bzip2
tar -xvf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make && make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so
ln -sfv libbz2.so.1.0.8 /usr/lib/libbz2.so.1
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
cd ..
sync
# not removing bc symlinks

# Xz
tar -xvf xz-5.8.2.tar.xz
cd xz-5.8.2
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.2
make && make install
cd ..
sync
rm -rf xz-5.8.2

# Lz4
tar -xvf lz4-1.10.0.tar.gz
cd lz4-1.10.0
make BUILD_STATIC=no PREFIX=/usr && make BUILD_STATIC=no PREFIX=/usr install
cd ..
sync
rm -rf lz4-1.10.0

# Zstd
tar -xvf zstd-1.5.7.tar.gz
cd zstd-1.5.7
make prefix=/usr && make prefix=/usr install
rm -v /usr/lib/libzstd.a
cd ..
sync
rm -rf zstd-1.5.7

# File
tar -xvf file-5.46.tar.gz
cd file-5.46
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf file-5.46

# Readline
tar -xvf readline-8.3.tar.gz
cd readline-8.3
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
sed -e '270a\
     else\
       chars_avail = 1;'      \
    -e '288i\   result = -1;' \
    -i.orig input.c
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.3
make SHLIB_LIBS="-lncursesw" && make install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.3
cd ..
sync
rm -rf readline-8.3

# Pcre2
tar -xvf pcre2-10.47.tar.bz2
cd pcre2-10.47
./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/pcre2-10.47 \
            --enable-unicode                    \
            --enable-jit                        \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static
make && make install
cd ..
sync
rm -rf pcre2-10.47

# M4
tar -xvf m4-1.4.21.tar.xz
cd m4-1.4.21
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf m4-1.4.21

# Bc
tar -xvf bc-7.0.3.tar.xz
cd bc-7.0.3
CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
make && make install
cd ..
sync
rm -rf bc-7.0.3

# Flex
tar -xvf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/flex-2.6.4
make && make install
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1
cd ..
sync

# Tcl
tar -xvf tcl8.6.17-src.tar.gz
cd tcl8.6.17
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath
make
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.12|/usr/lib/tdbc1.1.12|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12/generic|/usr/include|"     \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12/library|/usr/lib/tcl8.6|"  \
    -e "s|$SRCDIR/pkgs/tdbc1.1.12|/usr/include|"             \
    -i pkgs/tdbc1.1.12/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.4|/usr/lib/itcl4.3.4|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.4/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.4|/usr/include|"            \
    -i pkgs/itcl4.3.4/itclConfig.sh

unset SRCDIR
make install 
chmod 644 /usr/lib/libtclstub8.6.a
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3
cd ..
tar -xf ../tcl8.6.17-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.17
cp -v -r  ./html/* /usr/share/doc/tcl-8.6.17
cd ..
sync
# not removing bc symlinks

# Expect
tar -xvf expect5.45.4.tar.gz
cd expect5.45.4
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc15-1.patch
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make && make install
cd ..
sync
# ^ needed to path this V from book make sense
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
# again, no delete bc symlinks

# DejaGNU
tar -xvf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3
mkdir -v build
cd       build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
cd ../..
sync
rm -rf dejagnu-1.6.3

# Pkgconf
tar -xvf pkgconf-2.5.1.tar.xz
cd pkgconf-2.5.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1
make && make install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
cd ..
sync
# no deleting bc symlink

# Binutils
tar -xvf binutils-2.46.0.tar.xz
cd binutils-2.46.0
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu
make tooldir=/usr
# critical to check this one:
make -k check || true
grep '^FAIL:' $(find -name '*.log')

make tooldir=/usr install
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/
cd ../..
sync
rm -rf binutils-2.46.0

# GMP
tar -xvf gmp-6.3.0.tar.xz
cd gmp-6.3.0
sed -i '/long long t1;/,+1s/()/(...)/' configure
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0	\
	    --host=none-linux-gnu
make && make html
# test suite critical:
make check 2>&1 | tee gmp-check-log
# next should output 199
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install && make install-html
cd ..
sync
rm -rf gmp-6.3.0

# MPFR
tar -xvf mpfr-4.2.2.tar.xz
cd mpfr-4.2.2
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2
make && make html
# test suite critical:
make check
make install && make install-html
cd ..
sync
rm -rf mpfr-4.2.2

# MPC
tar -xvf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1
make && make html
make install && make install-html
cd ..
sync
rm -rf mpfr-4.2.2

# Attr
tar -xvf attr-2.5.2.tar.gz
cd attr-2.5.2
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2
make && make install
cd ..
sync
rm -rf attr-2.5.2

# Acl
tar -xvf acl-2.3.2.tar.xz
cd acl-2.3.2
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2
make && make install
cd ..
sync
rm -rf acl-2.3.2

# Libcap
tar -xvf libcap-2.77.tar.xz
cd libcap-2.77
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make prefix=/usr lib=lib install
cd ..
sync
rm -rf libcap-2.77

# Libxcrypt
tar -xvf libxcrypt-4.5.2.tar.xz
cd libxcrypt-4.5.2
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
make && make install
cd ..
sync
rm -rf libxcrypt-4.5.2

# Shadow
tar -xvf shadow-4.19.3.tar.xz
cd shadow-4.19.3
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs
touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --disable-logind    \
            --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man
pwconv
grpconv
mkdir -p /etc/default
useradd -D --gid 999
echo -e "admin\nadmin" | passwd root
cd ..
sync
rm -rf shadow-4.19.3

# GCC
#tar -xvf gcc-15.2.0.tar.xz
cd gcc-15.2.0
sed -i 's/char [*]q/const &/' libgomp/affinity-fmt.c
sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
rm -rf build
mkdir -v build
cd build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib
make
ulimit -s -H unlimited
make install
chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/15.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib # ln: failed to create symoblic link '/usr/lib/cpp': File exists
ln -sv gcc.1 /usr/share/man/man1/cc.1 # ln: failed to create symbolic link '/usr/share/man/man1/cc.1': File exists
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
#echo 'int main(){}' | cc -x c - -v -Wl,--verbose &> dummy.log
#readelf -l a.out | grep ': /lib'
#grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
#grep -B4 '^ /usr/include' dummy.log
#grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
#grep "/lib.*/libc.so.6 " dummy.log
#grep found dummy.log
#rm -v a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd ../..
sync
# not deleting, symlinks

# Ncurses
cd ncurses-6.6
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
make && make DESTDIR=$PWD/dest install
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp --remove-destination -av dest/* /
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done
ln -sfv libncursesw.so /usr/lib/libcurses.so
cp -v -R doc -T /usr/share/doc/ncurses-6.6
cd ..
sync

# Sed
tar -xvf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr
make && make html && make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9
cd ..
sync
rm -rf sed-4.9

# Psmisc
tar -xvf psmisc-23.7.tar.xz
cd psmisc-23.7
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf psmisc-23.7

# Gettext
tar -xvf gettext-1.0.tar.xz
cd gettext-1.0
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-1.0
make && make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
sync
rm -rf gettext-1.0

# Bison
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make && make install
cd ..
sync
rm -rf bison-3.8.2

# Grep
tar -xvf grep-3.12.tar.xz
cd grep-3.12
sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make && make install
cd ..
sync
rm -rf grep-3.12

# Bash
rm -rf bash-5.3
tar -xvf bash-5.3.tar.gz
cd bash-5.3
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3
make && make install
cd ..
sync
rm -rf bash-5.3
