#!/bin/bash

SCRIPT_REPO="https://git.linuxtv.org/v4l-utils.git"
SCRIPT_COMMIT="9bdabf8793f40e5df74435b2df94b5567b55805d"

ffbuild_enabled() {
    [[ $TARGET != *-linux-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" v4l-utils
    cd v4l-utils || exit 1

    if [[ -x ./autogen.sh ]]; then
        ./autogen.sh
    else
        autoreconf -fi
    fi

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    myconf+=(--host="$FFBUILD_TOOLCHAIN")

    ./configure "${myconf[@]}"
    make -j"$(nproc || echo 4)" -C lib
    make -C lib install
}

ffbuild_configure() {
    echo --enable-libv4l2
}

ffbuild_unconfigure() {
    echo --disable-libv4l2
}
