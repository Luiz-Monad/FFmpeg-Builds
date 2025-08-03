#!/bin/bash

SCRIPT_REPO="https://github.com/fraunhoferhhi/vvenc.git"
SCRIPT_COMMIT="3d433fcbca16af3e8f9525020383880d1808ee52"

ffbuild_enabled() {
    [[ $TARGET == armhf-* ]] && return $FFBUILD_FALSE
    # (( $(ffbuild_ffver) <= 700 )) && return $FFBUILD_FALSE
    # LF: I enabled this
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local armsimd=()
    if [[ $TARGET == armhf-* || $TARGET == aarch64-* ]]; then
        armsimd+=( -DVVENC_ENABLE_ARM_SIMD=ON )

        if [[ "$CC" != *clang* ]]; then
            export CFLAGS="$CFLAGS -fpermissive -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
            export CXXFLAGS="$CXXFLAGS -fpermissive -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
        else
            export CFLAGS="$CFLAGS -Wno-error=deprecated-literal-operator"
            export CXXFLAGS="$CXXFLAGS -Wno-error=deprecated-literal-operator"
        fi
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF -DVVENC_LIBRARY_ONLY=ON -DVVENC_ENABLE_WERROR=OFF -DVVENC_ENABLE_LINK_TIME_OPT=OFF -DEXTRALIBS="-lstdc++" "${armsimd[@]}" ..

    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 700 )) || return $FFBUILD_TRUE
    echo --disable-libvvenc
}
