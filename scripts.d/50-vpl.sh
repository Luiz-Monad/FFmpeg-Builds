#!/bin/bash

SCRIPT_REPO="https://github.com/intel/libvpl.git"
SCRIPT_COMMIT="c45b5d786bf7cdabbe49ff1bab78693ad78feb78"

ffbuild_enabled() {
    [[ $TARGET == aarch64-* ]] && return $FFBUILD_FALSE
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_BINDIR="$FFBUILD_PREFIX"/bin -DCMAKE_INSTALL_LIBDIR="$FFBUILD_PREFIX"/lib \
        -DBUILD_DISPATCHER=ON -DBUILD_DEV=ON \
        -DBUILD_PREVIEW=OFF -DBUILD_TOOLS=OFF -DBUILD_TOOLS_ONEVPL_EXPERIMENTAL=OFF -DINSTALL_EXAMPLE_CODE=OFF \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..

    ninja -j$(nproc)
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{etc,share}

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/vpl.pc
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    echo --disable-libvpl
}
