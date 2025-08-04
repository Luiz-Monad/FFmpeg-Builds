#!/bin/bash

SCRIPT_REPO="https://code.videolan.org/videolan/libplacebo.git"
SCRIPT_COMMIT="686ed7e80dc711fe2f6af572f1b4f4c259791a25"

ffbuild_enabled() {
    # (( $(ffbuild_ffver) <= 600 )) && return $FFBUILD_TRUE
    # return $FFBUILD_FALSE
    # LF: I enabled this
    return $FFBUILD_TRUE
}

ffbuild_dockerdl() {
    default_dl .
    echo "git submodule update --init --recursive --depth=1 --filter=blob:none"
}

ffbuild_dockerbuild() {
    sed -i 's/DPL_EXPORT/DPL_STATIC/' src/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dvulkan=enabled
        -Dvk-proc-addr=disabled
        -Dvulkan-registry="$FFBUILD_PREFIX"/share/vulkan/registry/vk.xml
        -Dshaderc=enabled
        -Dglslang=disabled
        -Ddemos=false
        -Dtests=false
        -Dbench=false
        -Dfuzz=false
    )

    if [[ $TARGET == *-windows-* ]]; then
        myconf+=(
            -Dd3d11=enabled
        )
    fi

    if [[ $TARGET == *-windows-* || $TARGET == *-linux-* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return $FFBUILD_FALSE
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libplacebo.pc
}

ffbuild_configure() {
    echo --enable-libplacebo
}

ffbuild_unconfigure() {
    echo --disable-libplacebo
}
