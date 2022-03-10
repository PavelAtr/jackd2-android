#!/bin/bash

set -e
umask 022

. cross.cfg

CWD=`pwd`
export DEBARCH="arm64"
export INSTALL_DIR=$CWD/install/jack2
export TMPDIR=/tmp/jack2

rm -r $INSTALL_DIR/usr || true
rm -r $TMPDIR || true
mkdir -p $TMPDIR
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/usr/include/
mkdir -p $INSTALL_DIR/usr/lib/$TARGET/jack
mkdir -p $INSTALL_DIR/usr/bin


export DESTDIR="$INSTALL_DIR"

cd $CWD/android-shm
make clean
make
make install

cd $CWD/libbthread
make clean || true
autoreconf -i
./configure --prefix=/usr --host=$TARGET
make
install -D -m 644 bthread.h $DESTDIR/usr/include/
install -D -m 755 .libs/libbthread.* $DESTDIR/usr/lib/$TARGET/

export CXXFLAGS="-I$INSTALL_DIR/usr/include -U__ANDROID__ -DUSE_LIBANDROIDSHM -DUSE_POSIX_SHM -DUSE_LIBBTHREAD -DUSE_SHMSEMAPHORE"
export CFLAGS=$CXXFLAGS
export LDFLAGS="-L$INSTALL_DIR/usr/lib/$TARGET -landroid-shm -lbthread"

cd $CWD/jack2
./waf clean || true
./waf configure --prefix=/usr --libdir=/usr/lib/$TARGET --firewire=no
./waf -v --destdir=$TMPDIR
./waf -v install --destdir=$DESTDIR

$CXX -fPIC -O0 -g -Wall -DSERVER_SIDE -DUSE_LIBBTHREAD -Wno-deprecated \
-shared -I posix/ -I common/ -I common/jack/  -I linux/ -I $DESTDIR/usr/include/ \
android/JackOpenSLESDriver.cpp android/opensl_io.c \
-L$DESTDIR/usr/lib/$TARGET -ljackserver -lOpenSLES -o $DESTDIR/usr/lib/$TARGET/jack/jack_opensles.so

cd $CWD

dpkg-deb --build $INSTALL_DIR jack2-android_1.0-android9_$DEBARCH.deb
