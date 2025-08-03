#!/bin/bash

SCRIPT_REPO="https://github.com/cisco/openh264.git"
SCRIPT_COMMIT="0c9a557a9a6f1d267c4d372221669a8ae69ccda0"

ffbuild_enabled() {
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        INCLUDE_PREFIX="$FFBUILD_PREFIX"/include/wels
        BUILDTYPE=Release
        DEBUGSYMBOLS=False
        LIBDIR_NAME=lib
        CC="$CC"
        CXX="$CXX"
        AR="$AR"
    )

    if [[ $TARGET == x86_64-windows-* ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=x86_64
        )
    elif [[ $TARGET == aarch64-windows-* ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=aarch64
        )
    elif [[ $TARGET == x86_64-linux-* ]]; then
        myconf+=(
            OS=linux
            ARCH=x86_64
        )
    elif [[ $TARGET == aarch64-linux-* ]]; then
        myconf+=(
            OS=linux
            ARCH=aarch64
        )
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    make -j$(nproc) "${myconf[@]}" install-static
}

ffbuild_configure() {
    echo --enable-libopenh264
}

ffbuild_unconfigure() {
    echo --disable-libopenh264
}
