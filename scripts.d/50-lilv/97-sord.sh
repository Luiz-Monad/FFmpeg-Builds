#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/sord.git"
SCRIPT_COMMIT="91bb85f4f1d93739dca77b8b885d884c1d8a07e5"

ffbuild_enabled() {
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Ddocs=disabled
        -Dtools=disabled
        -Dtests=disabled
    )

    if [[ $TARGET == *-windows-* || $TARGET == *-linux-* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}
