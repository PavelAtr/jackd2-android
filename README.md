# jackd2-android

Linux environment on Android smartphone can be created using Termux.
The /system and /apex directories must be forwarded to the environment.

Thus, we have two sets of libraries in Linux chroot:

- ABI "aarch64-linux-android" (Android libraries including sound driver libOpenSLES.so)

- ABI "aarch64-linux-gnu" (Linux Distribution Linux ABI).

It will not work to mix ABIs in one application (link with different ABIs), therefore
the Jackd2 server itself needs to be built with ABI aarch64-linux-android,
since it uses a sound driver. And for client programs with ABI
aarch64-linux-gnu additionally build the libjack.so library with this ABI.

bash ./submodules.sh

2-step assembly:

1. Cross-compile using the Android NDK toolchain (edit cross.cfg):

bash ./10_build_jack2.sh

2. On an Android smartphone in a Linux environment, native compilation:

bash ./20_build_libjack2.sh

Example launching client applications and sound server on smartphone:

shm-launch ./ardour.sh

No root privileges needed.
