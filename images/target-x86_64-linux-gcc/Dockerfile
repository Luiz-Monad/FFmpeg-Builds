ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
FROM $GH_REPO/runner-$RUNNER:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-x86_64-linux-gnu g++-x86_64-linux-gnu binutils-x86_64-linux-gnu \
    pkg-config qemu-user-static && \
    rm -rf /var/lib/apt/lists/*

ENV FFBUILD_TOOLCHAIN=x86_64-linux-gnu \
    FFBUILD_RUST_TARGET="x86_64-unknown-linux-gnu" \
    FFBUILD_ARCH_FLAGS="-march=x86-64 -mtune=generic -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=x86_64 --target-os=linux"

RUN \
    rustup target add "$FFBUILD_RUST_TARGET" && \
    mkdir -p "$CARGO_HOME" && \
    echo "[target.$FFBUILD_RUST_TARGET]" >> "$CARGO_HOME"/config.toml && \
    echo "linker = \"${FFBUILD_TOOLCHAIN}-gcc\"" >> "$CARGO_HOME"/config.toml && \
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
    CC="${FFBUILD_TOOLCHAIN}-gcc" \
    CXX="${FFBUILD_TOOLCHAIN}-g++" \
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
