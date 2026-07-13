########## ACTUALLY BUILDING STUFF #########

set -e
sudo -u lfs -i << 'EOF_LFS_2'
source ~/.bashrc
source ~/.bash_profile

export LFS=/mnt/lfs
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=/usr/bin:/bin:$LFS/tools/bin
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS=-j$(nproc)

set -e
cd $LFS/sources

# Binutils
tar -xvf binutils-2.46.0.tar.xz
cd binutils-2.46.0
mkdir -v build
cd build
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu
make && make install
cd ../..
sync
rm -rf binutils-2.46.0/

# GCC
tar -xvf gcc-15.2.0.tar.xz 
cd gcc-15.2.0
tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

sed -e '/m64=/s/lib64/lib/' \
	-i.orig gcc/config/i386/t-linux64

mkdir -v build
cd build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.43 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++
#    --disable-libcody \
#    --disable-bootstrap \
#    CXX=g++ \
#    CXXFLAGS="-O2 -std=c++20"

make && make install
cd ..
touch include/limits.h
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
cd ..
sync
rm -rf gcc-15.2.0

# Linux API Headers
tar -xvf linux-6.18.10.tar.xz 
cd linux-6.18.10
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
cd ..
sync

# Glibc
tar -xvf glibc-2.43.tar.xz
cd glibc-2.43
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
patch -Np1 -i ../glibc-fhs-1.patch
mkdir -v build
cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4
make && make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
echo 'int main(){}' | $LFS_TGT-gcc -x c - -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log
grep -B3 "^ $LFS/usr/include" dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v a.out dummy.log

cd ../.. 
sync
# not removing bc symlink
rm -rf linux-6.18.10
# ^ removing to clean up for building kernel in chroot-building-pt2

# Libstdc++
# need to extract gcc again:
tar -xvf gcc-15.2.0.tar.xz
cd gcc-15.2.0/
mkdir -v build
cd       build
../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0
make && make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
cd ../..
sync
rm -rf gcc-15.2.0/

# CHPT. 6
#
# M4-1.4.21
tar -xvf m4-1.4.21.tar.xz
cd m4-1.4.21
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf m4-1.4.21

# Ncurses
tar -xvf ncurses-6.6.tar.gz
cd ncurses-6.6
mkdir build
pushd build
  ../configure --prefix=$LFS/tools AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic $LFS/tools/bin
popd
./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk
make && make DESTDIR=$LFS install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h
# not deleting ncurses directory yet, idk abt that symlink
cd ..
sync

# Bash
tar -xvf bash-5.3.tar.gz
cd bash-5.3
./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc
make && make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
cd ..
sync
# not deleting again, to avoid linking conflicts if removed

#Coreutils
tar -xvf coreutils-9.10.tar.xz
cd coreutils-9.10
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make && make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
cd ..
sync
rm -rf coreutils-9.10

#Diffutils
tar -xvf diffutils-3.12.tar.xz
cd diffutils-3.12
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf diffutils-3.12

# File
tar -xvf file-5.46.tar.gz
cd file-5.46
mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file && make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la
cd ..
sync
rm -rf file-5.46

#Findutils
tar -xvf findutils-4.10.0.tar.xz
cd findutils-4.10.0
./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf findutils-4.10.0

# Gawk
tar -xvf gawk-5.3.2.tar.xz
cd gawk-5.3.2
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf gawk-5.3.2

# Grep

tar -xvf grep-3.12.tar.xz
cd grep-3.12
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf grep-3.12

# Gzip
tar -xvf gzip-1.14.tar.xz
cd gzip-1.14
./configure --prefix=/usr --host=$LFS_TGT
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf gzip-1.14

# Make
tar -xvf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf make-4.4.1

# Patch
tar -xvf patch-2.8.tar.xz
cd patch-2.8
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf patch-2.8

# Sed
tar -xvf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf sed-4.9

# Tar 
tar -xvf tar-1.35.tar.xz
cd tar-1.35
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make && make DESTDIR=$LFS install
cd ..
sync
rm -rf tar-1.35

# Xz
tar -xvf xz-5.8.2.tar.xz
cd xz-5.8.2
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.2
make && make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la
cd ..
sync
rm -rf xz-5.8.2

# Binutils (Pass 2)
tar -xvf binutils-2.46.0.tar.xz
cd binutils-2.46.0
sed '6031s/$add_dir//' -i ltmain.sh
mkdir -v build
cd       build
../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-new-dtags         \
    --enable-default-hash-style=gnu
make && make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
cd ../..
sync
rm -rf binutils-2.46.0

# GCC (Pass 2)
tar -xvf gcc-15.2.0.tar.xz
cd gcc-15.2.0
tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
mkdir -v build
cd       build
../configure                   \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --target=$LFS_TGT          \
    --prefix=/usr              \
    --with-build-sysroot=$LFS  \
    --enable-default-pie       \
    --enable-default-ssp       \
    --disable-nls              \
    --disable-multilib         \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libsanitizer     \
    --disable-libssp           \
    --disable-libvtv           \
    --enable-languages=c,c++   \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc
make && make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc
# bc symlink, not deleting
sync
EOF_LFS_2
