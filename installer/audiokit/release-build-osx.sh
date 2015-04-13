#!/bin/bash
#
# Build the Csound 32-bit float libraries and update the AudioKit framework for OS X
#
# (c) 2015 Stephane Peter
#

# Default: AudioKit in the same parent directory as csound
AK_ROOT=${AK_ROOT:-$PWD/../../../AudioKit/AudioKit/Platforms/OSX}
BUILD_TYPE=${BUILD_TYPE:-Release}

if ! test -d ${AK_ROOT}; then
    echo "Destination AudioKit OSX root does not exist: $AK_ROOT"
    exit 1
fi

echo "Building Csound (float) for ${BUILD_TYPE} ..."
cp Custom-ak.cmake ../../Custom.cmake

mkdir osx
cd osx

cmake ../../.. -DBUILD_INSTALLER=1 -DCMAKE_INSTALL_PREFIX=$BUILD_TYPE -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_OSX_ARCHITECTURES="i386;x86_64" -DBUILD_TESTS=0 -DBUILD_CSOUND_AC=1 -DBUILD_FAUST_OPCODES=1 -DUSE_DOUBLE=0 -DUSE_CURL=0 -DBUILD_IMAGE_OPCODES=0
make -j6 install

# Copy new libraries and headers for Csound and its opcodes to the AudioKit framework
cd $BUILD_TYPE/CsoundLib.framework

# Change the library name for libsndfile in CSoundLib and libcsound.dylib
install_name_tool -change /Users/megastep/src/libsndfile/src/Debug/libsndfile.1.dylib @loader_path/../../libs/libsndfile.1.dylib CsoundLib
cp CsoundLib ${AK_ROOT}/CsoundLib.framework/

cp Headers/* ${AK_ROOT}/../Common/csound/

cd Resources/Opcodes
for a in *.dylib; do
    cp $a ${AK_ROOT}/CsoundLib.framework/Resources/Opcodes/
done


echo "... finished."
