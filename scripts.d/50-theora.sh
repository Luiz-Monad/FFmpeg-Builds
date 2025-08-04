#!/bin/bash

SCRIPT_REPO="https://github.com/xiph/theora.git"
SCRIPT_COMMIT="23161c4a63fd9f9d09b9e972f95def2d56c777af"

ffbuild_enabled() {
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --disable-examples
        --disable-oggtest
        --disable-vorbistest
        --disable-spec
        --disable-doc
    )

    if [[ $TARGET == *-windows-* || $TARGET == *-linux-* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
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
    echo --enable-libtheora
}

ffbuild_unconfigure() {
    echo --disable-libtheora
}
