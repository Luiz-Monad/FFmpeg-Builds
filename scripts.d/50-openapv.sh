#!/bin/bash

SCRIPT_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
SCRIPT_COMMIT="9328d09dfe19edcde42c28145d0e55128ceda449"

ffbuild_enabled() {
    # (( $(ffbuild_ffver) <= 701 )) && return $FFBUILD_TRUE
    # return $FFBUILD_FALSE
    # LF: I enabled this
    return $FFBUILD_TRUE
}

ffbuild_dockerdl() {
    default_dl .
    echo "git fetch --unshallow --filter=blob:none"
}

ffbuild_dockerbuild() {
    # No need to build this
    echo > app/CMakeLists.txt

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DCMAKE_BUILD_TYPE=Release \
        -DOAPV_APP_STATIC_BUILD=ON -DENABLE_TESTS=OFF ..

    make -j$(nproc)
    make install

    mv "$FFBUILD_PREFIX"/lib{/oapv/liboapv.a,}
    rm -rf "$FFBUILD_PREFIX"/{bin,lib/oapv,include/oapv/oapv_exports.h,lib/liboapv.so*}

    {
        echo "Libs.private: -lm"
        echo "Cflags.private: -DOAPV_STATIC_DEFINE"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/oapv.pc
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    (( $(ffbuild_ffver) > 701 )) || return 0
    echo --disable-liboapv
}
