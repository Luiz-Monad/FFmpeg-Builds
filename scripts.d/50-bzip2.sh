#!/bin/bash

SCRIPT_REPO="https://sourceware.org/git/bzip2.git"
SCRIPT_COMMIT="6a8690fc8d26c815e798c588f796eabe9d684cf0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" bzip2
    cd bzip2

    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-bzlib
}

ffbuild_unconfigure() {
    echo --disable-bzlib
}
