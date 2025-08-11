ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
FROM $GH_REPO/runner-$RUNNER:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang lld \
    pkg-config qemu-user-static && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

ENV VERSION_SDK="13114758" \
    VERSION_NDK="28.1.13356709" \
    ANDROID_SDK_HOME="/opt/android-sdk" \
    ANDROID_NDK_HOME="${ANDROID_SDK_HOME}/ndk/${VERSION_NDK}"

ENV LLVM_ROOT="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64" \
    LLVM_BIN="${LLVM_ROOT}/bin"

RUN install-android-sdk

ENV TARGET_TRIPLE="aarch64-linux-android" \
    TARGET_API="21" \
    TARGET_ABI="arm64-v8a"

ENV FFBUILD_TOOLCHAIN="aarch64-linux-android" \
    FFBUILD_RUST_TARGET="aarch64-linux-android" \
    FFBUILD_ARCH_FLAGS="-march=armv8-a -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=aarch64 --cpu=armv8-a --target-os=android" \
    FFBUILD_SYSTEM="android" \
    FFBUILD_SYSTEM_NAME="Android" \
    FFBUILD_VERSION="${TARGET_API}" \
    FFBUILD_CPU_ENDIAN="little" \
    FFBUILD_CPU_FAMILY="aarch64" \
    FFBUILD_CPU="armv8-a"

ENV PATH="${LLVM_BIN}:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- ${FFBUILD_CONFIGURE_FLAGS}" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX="/opt/ffbuild" \
    FFBUILD_CMAKE_TOOLCHAIN="/toolchain.cmake" \
    PKG_CONFIG="pkg-config" \
    PKG_CONFIG_LIBDIR="/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig" \
    COMPILER_ROOT="${LLVM_ROOT}" \
    COMPILER_SYSROOT="${LLVM_ROOT}/sysroot" \
    CC="${LLVM_BIN}/${TARGET_TRIPLE}${TARGET_API}-clang" \
    CXX="${LLVM_BIN}/${TARGET_TRIPLE}${TARGET_API}-clang++" \
    LD="${LLVM_BIN}/ld" \
    AR="${LLVM_BIN}/llvm-ar" \
    RANLIB="${LLVM_BIN}/llvm-ranlib" \
    NM="${LLVM_BIN}/llvm-nm" \
    STRIP="${LLVM_BIN}/llvm-strip" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong -ffunction-sections -fdata-sections -D__ANDROID_API__=${TARGET_API}" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong -ffunction-sections -fdata-sections -D__ANDROID_API__=${TARGET_API}" \
    LDFLAGS="-static -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -Wl,--gc-sections -Wl,--strip-all" \
    CPPFLAGS="-I/opt/ffbuild/include -D__ANDROID_API__=${TARGET_API}" \
    STAGE_CFLAGS="" \
    STAGE_CXXFLAGS=""

ADD toolchain.cmake /toolchain.cmake.template
ADD cross.meson /cross.meson.template
ADD config.toml /config.toml.template

RUN envsubst < /toolchain.cmake.template > /toolchain.cmake && \
    envsubst < /cross.meson.template > /cross.meson && \
    envsubst < /config.toml.template > "$CARGO_HOME/config.toml"

RUN rustup target add "$FFBUILD_RUST_TARGET"
