ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
FROM $GH_REPO/runner-$RUNNER:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang lld \
    binutils-aarch64-linux-gnu gcc-aarch64-linux-gnu \
    pkg-config qemu-user-static && \
    rm -rf /var/lib/apt/lists/*

ENV FFBUILD_TOOLCHAIN=aarch64-linux-gnu \
    FFBUILD_RUST_TARGET="aarch64-unknown-linux-gnu" \
    FFBUILD_ARCH_FLAGS="-march=armv8-a -mtune=cortex-a72 -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=aarch64 --cpu=armv8-a --target-os=linux"

RUN \
    rustup target add "$FFBUILD_RUST_TARGET" && \
    mkdir -p "$CARGO_HOME" && \
    echo "[target.$FFBUILD_RUST_TARGET]" >> "$CARGO_HOME"/config.toml && \
    echo "linker = \"clang --target=${FFBUILD_TOOLCHAIN}\"" >> "$CARGO_HOME"/config.toml && \
    echo "ar = \"${FFBUILD_TOOLCHAIN}-gcc-ar\"" >> "$CARGO_HOME"/config.toml && \
    echo "" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ADD gen-implib.sh /usr/bin/gen-implib
RUN git clone --filter=blob:none --depth=1 https://github.com/yugr/Implib.so /opt/implib

ENV PATH="/usr/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- ${FFBUILD_CONFIGURE_FLAGS}" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    COMPILER_SYSROOT=/usr/$FFBUILD_TOOLCHAIN \
    CC="clang --target=${FFBUILD_TOOLCHAIN}" \
    CXX="clang++ --target=${FFBUILD_TOOLCHAIN}" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-nm" \
    STRIP="${FFBUILD_TOOLCHAIN}-strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static -static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -Wl,--gc-sections -Wl,--strip-all" \
    CPPFLAGS="-I/opt/ffbuild/include" \
    STAGE_CFLAGS="" \
    STAGE_CXXFLAGS=""
