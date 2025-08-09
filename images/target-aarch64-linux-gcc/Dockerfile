ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
FROM $GH_REPO/runner-$RUNNER:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu \
    pkg-config qemu-user-static && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

ENV FFBUILD_TOOLCHAIN="aarch64-linux-gnu" \
    FFBUILD_RUST_TARGET="aarch64-unknown-linux-gnu" \
    FFBUILD_ARCH_FLAGS="-march=armv8-a -mtune=cortex-a72 -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=aarch64 --cpu=armv8-a --target-os=linux" \
    FFBUILD_SYSTEM="linux" \
    FFBUILD_SYSTEM_NAME="Linux" \
    FFBUILD_VERSION="4.18.20" \
    FFBUILD_CPU_ENDIAN="little" \
    FFBUILD_CPU_FAMILY="aarch64" \
    FFBUILD_CPU="armv8-a"

ENV PATH="/usr/${FFBUILD_TOOLCHAIN}/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- ${FFBUILD_CONFIGURE_FLAGS}" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX="/opt/ffbuild" \
    FFBUILD_CMAKE_TOOLCHAIN="/toolchain.cmake" \
    PKG_CONFIG="pkg-config" \
    PKG_CONFIG_LIBDIR="/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig" \
    COMPILER_ROOT="/usr/${FFBUILD_TOOLCHAIN}" \
    COMPILER_SYSROOT="/usr/${FFBUILD_TOOLCHAIN}/sysroot" \
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

ADD toolchain.cmake /toolchain.cmake.template
ADD cross.meson /cross.meson.template
ADD config.toml /config.toml.template
ADD gen-implib.sh /gen-implib.sh.template

RUN export AMP="\$" \
    envsubst < /toolchain.cmake.template > /toolchain.cmake && \
    envsubst < /cross.meson.template > /cross.meson && \
    envsubst < /config.toml.template > "$CARGO_HOME/config.toml" && \
    envsubst < /gen-implib.sh.template > /usr/bin/gen-implib

RUN git clone --filter=blob:none --depth=1 https://github.com/yugr/Implib.so /opt/implib

RUN rustup target add "$FFBUILD_RUST_TARGET"
