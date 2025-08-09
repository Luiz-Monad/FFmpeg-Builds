ARG RUNNER=base
ARG GH_REPO=ghcr.io/luiz-monad/ffmpeg-builds
FROM $GH_REPO/runner-$RUNNER:latest

# Install llvm-mingw
RUN install-llvm-mingw

# LLVM/Clang workarounds for Windows headers
RUN \
    find /opt/llvm-mingw -name "include" -type d | while read incdir; do \
        if [ -f "$incdir/windows.h" ]; then \
            ln -sf windows.h "$incdir/Windows.h" || true; \
        fi; \
    done

# Prepare "cross" environment to heavily favour static builds
RUN \
    find /opt/llvm-mingw \
        -name "*.dll" \
        -or -name "*.dll.a" \
        -delete && \
    mkdir /opt/ffbuild

ENV FFBUILD_TOOLCHAIN="armv7-w64-mingw32" \
    FFBUILD_RUST_TARGET="thumbv7a-pc-windows-gnullvm" \
    FFBUILD_ARCH_FLAGS="-march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -mfpu=vfpv3-d16 -fPIC -DPIC" \
    FFBUILD_CONFIGURE_FLAGS="--arch=arm --cpu=cortex-a9 --target-os=mingw32"
    
RUN \
    rustup target add "$FFBUILD_RUST_TARGET" && \
    mkdir -p "$CARGO_HOME" && \
    echo "[target.$FFBUILD_RUST_TARGET]" >> "$CARGO_HOME"/config.toml && \
    echo "linker = \"${FFBUILD_TOOLCHAIN}-clang\"" >> "$CARGO_HOME"/config.toml && \
    echo "ar = \"${FFBUILD_TOOLCHAIN}-llvm-ar\"" >> "$CARGO_HOME"/config.toml && \
    echo "" >> "$CARGO_HOME"/config.toml

ADD toolchain.cmake /toolchain.cmake
ADD cross.meson /cross.meson

ENV PATH="/opt/llvm-mingw/bin:${PATH}" \
    FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- ${FFBUILD_CONFIGURE_FLAGS}" \
    FFBUILD_CROSS_PREFIX="${FFBUILD_TOOLCHAIN}-" \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    COMPILER_SYSROOT=/opt/llvm-mingw/$FFBUILD_TOOLCHAIN \
    CC="${FFBUILD_TOOLCHAIN}-clang" \
    CXX="${FFBUILD_TOOLCHAIN}-clang++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-llvm-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-llvm-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-llvm-nm" \
    OBJCOPY="${FFBUILD_TOOLCHAIN}-llvm-objcopy" \
    OBJDUMP="${FFBUILD_TOOLCHAIN}-llvm-objdump" \
    STRIP="${FFBUILD_TOOLCHAIN}-llvm-strip" \
    DLLTOOL="${FFBUILD_TOOLCHAIN}-dlltool" \
    WINDRES="${FFBUILD_TOOLCHAIN}-windres" \
    CFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-I/opt/ffbuild/include -O2 -pipe $FFBUILD_ARCH_FLAGS -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong -Wl,--gc-sections -Wl,--strip-all" \
    CPPFLAGS="-I/opt/ffbuild/include" \
    STAGE_CFLAGS="" \
    STAGE_CXXFLAGS=""
