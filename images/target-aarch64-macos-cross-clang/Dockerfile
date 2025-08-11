ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
# FROM ghcr.io/luiz-monad/osxcross/compiler-1.0-apple-binutils:latest AS osxcross-compiler
FROM ghcr.io/luiz-monad/osxcross/compiler-2.0-llvm-based:latest AS osxcross-compiler
FROM $GH_REPO/runner-$RUNNER:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang lld pkg-config qemu-user-static \
    cmake ninja-build yasm nasm autoconf automake libtool && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

RUN cargo install apple-codesign

# Copy prebuilt osx-cross compiler from a separate compiler image
COPY --from=osxcross-compiler /opt/osxcross /opt/osxcross

ENV OSX_SDK_VERSION="15.5"
ENV OSX_SDK_PATH="/opt/osxcross/SDK/MacOSX${OSX_SDK_VERSION}.sdk" \
    OSX_BIN_PATH="/opt/osxcross/bin"

ENV FFBUILD_TOOLCHAIN="aarch64-apple-darwin" \
    FFBUILD_RUST_TARGET="aarch64-apple-darwin" \
    FFBUILD_ARCH_FLAGS="-arch arm64 -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=arm64 --target-os=darwin" \
    FFBUILD_SYSTEM="darwin" \
    FFBUILD_SYSTEM_NAME="Darwin" \
    FFBUILD_VERSION="${OSX_SDK_VERSION}" \
    FFBUILD_CPU_ENDIAN="little" \
    FFBUILD_CPU_FAMILY="aarch64" \
    FFBUILD_CPU="arm64"

ENV PATH="${OSX_BIN_PATH}:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- ${FFBUILD_CONFIGURE_FLAGS}" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX="/opt/ffbuild" \
    FFBUILD_CMAKE_TOOLCHAIN="/toolchain.cmake" \
    PKG_CONFIG="pkg-config" \
    PKG_CONFIG_LIBDIR="/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig" \
    COMPILER_ROOT="${OSX_BIN_PATH}" \
    COMPILER_SYSROOT="${OSX_SDK_PATH}" \
    CC="${OSX_BIN_PATH}/o64-clang" \
    CXX="${OSX_BIN_PATH}/o64-clang++" \
    LD="${OSX_BIN_PATH}/ld" \
    AR="${OSX_BIN_PATH}/ar" \
    RANLIB="${OSX_BIN_PATH}/ranlib" \
    NM="${OSX_BIN_PATH}/nm" \
    STRIP="${OSX_BIN_PATH}/strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2" \
    LDFLAGS="-static -L/opt/ffbuild/lib -O2 -pipe" \
    CPPFLAGS="-I/opt/ffbuild/include" \
    STAGE_CFLAGS="" \
    STAGE_CXXFLAGS=""

ADD toolchain.cmake /toolchain.cmake.template
ADD cross.meson /cross.meson.template
ADD config.toml /config.toml.template

RUN envsubst < /toolchain.cmake.template > /toolchain.cmake && \
    envsubst < /cross.meson.template > /cross.meson && \
    envsubst < /config.toml.template > "$CARGO_HOME/config.toml"

RUN rustup target add "$FFBUILD_RUST_TARGET"
