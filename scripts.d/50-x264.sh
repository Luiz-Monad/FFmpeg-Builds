#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/x264.git"
SCRIPT_COMMIT="b35605ace3ddf7c1a5d67a2eb553f034aef41d55"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    local myconf=(
        --disable-cli
        --enable-static
        --enable-pic
        --disable-lavf
        --disable-swscale
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == *-windows-* || $TARGET == *-linux-* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libx264
}

ffbuild_unconfigure() {
    echo --disable-libx264
}

ffbuild_cflags() {
    return $FFBUILD_TRUE
}

ffbuild_ldflags() {
    return $FFBUILD_TRUE
}
