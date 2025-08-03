#!/bin/bash

SCRIPT_REPO="https://github.com/ARMmbed/mbedtls.git"
SCRIPT_COMMIT="v3.6.4"
SCRIPT_TAGFILTER="v3.*"

ffbuild_enabled() {
    return $FFBUILD_TRUE
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1"
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    # Let's hope this is just a false-positive
    export CFLAGS="$CFLAGS -Wno-error=array-bounds"
    if [[ $CC != *clang* ]]; then
        export CFLAGS="$CFLAGS -Wno-error=unterminated-string-initialization"
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DGEN_FILES=ON \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON -DUSE_SHARED_MBEDTLS_LIBRARY=OFF -DINSTALL_MBEDTLS_HEADERS=ON \
        ..
    make -j$(nproc)
    make install

    if [[ $TARGET == *-windows-* ]]; then
        echo "Libs.private: -lws2_32 -lbcrypt -lwinmm -lgdi32" >> "$FFBUILD_PREFIX"/lib/pkgconfig/mbedcrypto.pc
    fi
}
