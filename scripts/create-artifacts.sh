#!/bin/bash


build_target () {
    local arch=$1
    local sim=$2
    vm_build_target=ios-$arch-bootimage
    if [ "$3" == "buildjar" ] ; then
        local build_jar="build/$vm_build_target/classpath.jar build/$vm_build_target/binaryToObject/binaryToObject"
    fi

    pushd "$AVIAN" >/dev/null
    make -j arch=$arch platform=ios $sim process=compile bootimage=true build/$vm_build_target/bootimage-generator build/$vm_build_target/libavian.a $build_jar
    popd >/dev/null

    cp "$AVIAN/build/$vm_build_target/bootimage-generator" "$CACHE/bin/bootimage-generator.$arch"
    if [ "$build_jar" != "" ] ; then
        cp "$AVIAN/build/$vm_build_target/binaryToObject/binaryToObject" "$CACHE/bin/binaryToObject"
        cp "$AVIAN/build/$vm_build_target/classpath.jar" "$CACHE/classpath.jar"
        cp "$AVIAN/build/macosx-x86_64-interpret/libjvm.dylib"  "$CACHE/bin/libjvm.dylib"
    fi
}

cd `dirname $0`
AVIAN=../avian
CACHE=../build

mkdir -p "$AVIAN"
rm -rf "$CACHE"
mkdir -p "$CACHE"

AVIAN=$(cd "$AVIAN"; pwd)
CACHE=$(cd "$CACHE"; pwd)

if [ ! -f "$AVIAN/src/avian/common.h" ] ; then
    echo "Fetching Avian"
    (cd .. ; git clone https://github.com/ReadyTalk/avian.git) || exit 1
fi

echo "Compiling VM"
mkdir -p "$CACHE/bin"
build_target i386 'sim=true' buildjar
build_target x86_64 'sim=true'
build_target arm
build_target arm64

echo "Combine object files"
for arch in i386 x86_64 arm arm64 ; do
    rm -rf "$CACHE/$arch"
    mkdir -p "$CACHE/$arch"
    (cd "$CACHE/$arch" ; ar x "$AVIAN/build/ios-$arch-bootimage/libavian.a")
done
mkdir -p "$CACHE/lib"
for obj in `ls "$CACHE/arm/"*.o "$CACHE/arm64/"*.o "$CACHE/i386/"*.o "$CACHE/x86_64/"*.o | sed -e 's/.*bootimage_//g' | sort | uniq` ; do
    o_i386="" ; o_x86_64="" ; o_arm="" ; o_arm64=""
    if [ -f "$CACHE/i386/build_ios-i386-bootimage_$obj" ] ; then o_i386="$CACHE/i386/build_ios-i386-bootimage_$obj" ; fi
    if [ -f "$CACHE/x86_64/build_ios-x86_64-bootimage_$obj" ] ; then o_x86_64="$CACHE/x86_64/build_ios-x86_64-bootimage_$obj" ; fi
    if [ -f "$CACHE/arm/build_ios-arm-bootimage_$obj" ] ; then o_arm="$CACHE/arm/build_ios-arm-bootimage_$obj" ; fi
    if [ -f "$CACHE/arm64/build_ios-arm64-bootimage_$obj" ] ; then o_arm64="$CACHE/arm64/build_ios-arm64-bootimage_$obj" ; fi
    lipo -create -output "$CACHE/lib/$obj" $o_i386 $o_x86_64 $o_arm $o_arm64
done
rm -rf $CACHE/i386 $CACHE/x86_64 $CACHE/arm $CACHE/arm64
echo "Archiving object files"
pushd "$CACHE" >/dev/null
jar cf nativelib.jar lib bin
popd >/dev/null

echo "Installing maven plugin"
mvn -q install:install-file -Dfile=${CACHE}/nativelib.jar -DgroupId=org.crossmobile -DartifactId=avian-ios-maven-lib -Dversion=0.1 -Dpackaging=jar -Dclassifier=nativelib
mvn -q install:install-file -Dfile=${CACHE}/classpath.jar    -DgroupId=org.crossmobile -DartifactId=avian-ios-maven-lib -Dversion=0.1 -Dpackaging=jar -Dclassifier=classpath

echo -n "Do you want to remove build files and avian repository? [Y/n] "
read R
R=$(echo ${R:0:1} | awk '{print toupper($0)}')
if [ "$R" != "N" ] ; then
    echo "Deleting $AVIAN $CACHE"
    rm -rf "$AVIAN"
    rm -rf "$CACHE"
fi
