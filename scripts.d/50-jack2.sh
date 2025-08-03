#!/bin/bash

SCRIPT_REPO="https://github.com/jackaudio/jack2.git"
SCRIPT_COMMIT="4f58969432339a250ce87fe855fb962c67d00ddb"

ffbuild_enabled() {
    [[ $TARGET != *-linux-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" jack2
    cd jack2

    if [[ -x ./autogen.sh ]]; then
        ./autogen.sh --no-po4a
    else
        autoreconf -fi
    fi

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-symbol-versions
        --disable-shared
        --enable-static
        --with-pic
    )

    myconf+=(--host="$FFBUILD_TOOLCHAIN")

    ./configure "${myconf[@]}"
    make -j"$(nproc || echo 4)"
    make install
}

ffbuild_configure() {
    echo --enable-libjack
}

ffbuild_unconfigure() {
    echo --disable-libjack
}
