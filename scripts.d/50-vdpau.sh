#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/vdpau/libvdpau.git"
SCRIPT_COMMIT="eac1393480bc7c2209d4984819951cb9dc1e03d0"

ffbuild_enabled() {
    [[ $TARGET != *-linux-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" libvdpau
    cd libvdpau

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
    make -j"$(nproc || echo 4)"
    make install
}

ffbuild_configure() {
    echo --enable-vdpau
}

ffbuild_unconfigure() {
    echo --disable-vdpau
}
