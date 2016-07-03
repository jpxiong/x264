#!/bin/bash
#
#  by dingfeng <dingfeng@qiniu.com>
#

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
fi

# Detect OS
OS=`uname`
HOST_ARCH=`uname -m`
export CCACHE=; type ccache >/dev/null 2>&1 && export CCACHE=ccache
if [ $OS == 'Linux' ]; then
    export HOST_SYSTEM=linux-$HOST_ARCH
elif [ $OS == 'Darwin' ]; then
    export HOST_SYSTEM=darwin-$HOST_ARCH
fi

SOURCE=`pwd`


for version in armeabi armeabi-v7a arm64-v8a x86; do

  case $version in
    armeabi)
      PREFIX=$SOURCE/../libs/x264/armeabi
      SYSROOT=$ANDROID_NDK/platforms/android-14/arch-arm
      CROSS_PREFIX=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.8/prebuilt/$HOST_SYSTEM/bin/arm-linux-androideabi-
      CFLAGS="-O3 -Wall -fpic -mthumb \
             -finline-limit=300 -ffast-math \
             -Wno-psabi -Wa,--noexecstack -fomit-frame-pointer -fno-strict-aliasing \
             -DANDROID -DNDEBUG"
      EXTRA="--disable-asm"
      EXTRA_CFLAGS="-march=armv5te -mtune=xscale -msoft-float"
      EXTRA_LDFLAGS=""
./configure  --prefix=$PREFIX \
    --enable-pic \
    --enable-static \
    --enable-strip \
    --disable-asm \
    --host=arm-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="$CFLAGS $EXTRA_CFLAGS" 
    ;;

    armeabi-v7a)
      PREFIX=$SOURCE/../libs/x264/armeabi-v7a
      SYSROOT=$ANDROID_NDK/platforms/android-12/arch-arm
      CROSS_PREFIX=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/$HOST_SYSTEM/bin/arm-linux-androideabi-
      CFLAGS="-O3 -Wall -fpic -mthumb \
             -finline-limit=300 -ffast-math \
             -Wno-psabi -Wa,--noexecstack -fomit-frame-pointer -fno-strict-aliasing \
             -DANDROID -DNDEBUG"
      EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__"
      EXTRA_LDFLAGS="-nostdlib"
./configure  --prefix=$PREFIX \
    --enable-pic \
    --enable-static \
    --enable-strip \
    --disable-cli \
    --host=arm-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="$CFLAGS $EXTRA_CFLAGS" \ 
    --extra-ldflags="$EXTRA_LDFLAGS" 
    ;;
    
    arm64-v8a)
      PREFIX=$SOURCE/../libs/x264/arm64-v8a
      SYSROOT=$ANDROID_NDK/platforms/android-21/arch-arm64
      CROSS_PREFIX=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt/$HOST_SYSTEM/bin/aarch64-linux-android-
      EXTRA_CFLAGS="-march=armv8-a -mfpu=neon"
      EXTRA_LDFLAGS="-nostdlib"
./configure  --prefix=$PREFIX \
    --enable-pic \
    --enable-static \
    --enable-strip \
    --disable-cli \
    --host=aarch64-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT
    --extra-cflags="$EXTRA_CFLAGS" \
    --extra-ldflags="$EXTRA_LDFLAGS"
    ;;
    
    x86)
      PREFIX=$SOURCE/../libs/x264/x86
      SYSROOT=$ANDROID_NDK/platforms/android-14/arch-x86
      CROSS_PREFIX=$ANDROID_NDK/toolchains/x86-4.8/prebuilt/$HOST_SYSTEM/bin/i686-linux-android-
      EXTRA_CFLAGS="-march=i686"
./configure  --prefix=$PREFIX \
    --enable-pic \
    --enable-static \
    --enable-strip \
    --disable-cli \
    --host=i686-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="$EXTRA_CFLAGS" \
    ;;

    *)
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
  esac

make clean
make -j4
cp libx264.a ../libs/x264/$version/
echo "*****************************finish build verion $version . *********************";

done
