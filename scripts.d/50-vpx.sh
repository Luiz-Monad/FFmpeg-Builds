#!/bin/bash

SCRIPT_REPO="https://chromium.googlesource.com/webm/libvpx"
SCRIPT_COMMIT="ae32a476b2297ae435499acd24eafcf2ff47f0f5"

ffbuild_enabled() {
    [[ $TARGET == aarch64-windows-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    local myconf=(
        --disable-shared
        --enable-static
        --enable-pic
        --disable-examples
        --disable-tools
        --disable-docs
        --disable-unit-tests
        --enable-vp9-highbitdepth
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == x86_64-windows-* ]]; then
        myconf+=(
            --target=x86_64-win64-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == aarch64-windows-* ]]; then
        myconf+=(
            --target=arm64-win64-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == x86_64-linux-* ]]; then
        myconf+=(
            --target=x86_64-linux-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == aarch64-linux-* ]]; then
        myconf+=(
            --target=arm64-linux-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    # Work around strip breaking LTO symbol index
    "$RANLIB" "$FFBUILD_PREFIX"/lib/libvpx.a
}

ffbuild_configure() {
    echo --enable-libvpx
}

ffbuild_unconfigure() {
    echo --disable-libvpx
}
