#!/bin/bash

set -e
umask 022


CWD=`pwd`
export DEBARCH="arm64"
export INSTALL_DIR=$CWD/install/libjack2
export TMPDIR=/tmp/jack2
export TARGET=aarch64-linux-gnu

rm -r $INSTALL_DIR/usr || true
rm -r $TMPDIR || true
mkdir -p $TMPDIR
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/usr/lib/$TARGET
mkdir -p $INSTALL_DIR/usr/bin


export DESTDIR="$INSTALL_DIR"

cd $CWD/android-shm
make clean
make all
make install

export CXXFLAGS="-I$INSTALL_DIR/usr/include -U__ANDROID__ -DUSE_LIBANDROIDSHM -DUSE_POSIX_SHM -DUSE_SHMSEMAPHORE"
export CFLAGS=$CXXFLAGS
export LDFLAGS="-L$INSTALL_DIR/usr/lib/$TARGET -landroid-shm -lpthread"

cd $CWD/jack2
./waf clean
./waf configure --prefix=/usr --libdir=/usr/lib/$TARGET --firewire=no
./waf -v --destdir=$TMPDIR
mv build/common/libjack.so* $INSTALL_DIR/usr/lib/$TARGET/

cd $CWD

dpkg-deb --build $INSTALL_DIR libjack2-android_1.0_$DEBARCH.deb
