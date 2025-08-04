#!/bin/bash

SCRIPT_REPO="https://gitlab.freedesktop.org/mesa/drm.git"
SCRIPT_COMMIT="e4bd1ba753641672fe4f108142b94fa2a1a7220c"

ffbuild_enabled() {
    [[ $TARGET != *-linux-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=shared
        -Dudev=false
        -Dcairo-tests=disabled
        -Dvalgrind=disabled
        -Dexynos=disabled
        -Dfreedreno=disabled
        -Domap=disabled
        -Detnaviv=disabled
        -Dintel=enabled
        -Dnouveau=enabled
        -Dradeon=enabled
        -Damdgpu=enabled
    )

    if [[ $TARGET == *-linux-* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    gen-implib "$FFBUILD_PREFIX"/lib/{libdrm.so.2,libdrm.a}
    rm "$FFBUILD_PREFIX"/lib/libdrm*.so*

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libdrm.pc
}

ffbuild_configure() {
    echo --enable-libdrm
}

ffbuild_unconfigure() {
    echo --disable-libdrm
}
