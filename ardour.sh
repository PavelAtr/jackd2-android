#!/bin/bash

LD_LIBRARY_PATH=/system/lib64:/system/apex/com.android.runtime.release/lib64:/usr/lib/aarch64-linux-android \
    /usr/bin/jackd -r -dopensles -r44100 -p1024 -C2&
sleep 2
ardour
killall -9 jackd


