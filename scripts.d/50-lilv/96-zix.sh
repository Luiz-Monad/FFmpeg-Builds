#!/bin/bash

SCRIPT_REPO="https://github.com/drobilla/zix.git"
SCRIPT_COMMIT="2a9aa31da38fcffd40d350157486176cd30588a4"

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
        -Dbenchmarks=disabled
        -Dtests=disabled
        -Dtests_cpp=disabled
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
