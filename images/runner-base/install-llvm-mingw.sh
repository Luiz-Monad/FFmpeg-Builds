#!/bin/bash
set -xe

# Only install LLVM-MinGW for Windows targets
case "$TARGET" in
    *windows*) ;;
    *) echo "Target $TARGET does not need LLVM-MinGW"; exit 0 ;;
esac

LLVM_MINGW_VERSION="20250730"
BASE_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}"

# Detect host OS and architecture
HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH=$(uname -m)

case $HOST_OS in
    linux*)
        case $HOST_ARCH in
            x86_64)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-x86_64.tar.xz"
                LLVM_MINGW_SHA256="9ad92b430f6ef922eab04d0c99b41108ab2e76258dacda58b2bfd311b37055d5"
                EXTRACT_CMD="tar -xf"
                ;;
            aarch64|arm64)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-aarch64.tar.xz"
                LLVM_MINGW_SHA256="a7ef2d1070d5d24f9cf673cdaaa5efded3e30c1a7356a10162b74fca34998dfb"
                EXTRACT_CMD="tar -xf"
                ;;
            *)
                echo "Unsupported Linux architecture: $HOST_ARCH"
                exit 1
                ;;
        esac
        ;;
    darwin*)
        LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-macos-universal.tar.xz"
        LLVM_MINGW_SHA256="d8105065b31c1c7756ce59575760f22656864c4a690cbfebbd81a1031fa7f17b"
        EXTRACT_CMD="tar -xf"
        ;;
    msys*|cygwin*|mingw*)
        case $HOST_ARCH in
            x86_64)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-x86_64.zip"
                LLVM_MINGW_SHA256="043e2c9b8a6486ca74a7bd31107d343327460e259632662a838e02a43ff6ea3b"
                EXTRACT_CMD="unzip -q"
                ;;
            i686|i386)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-i686.zip"
                LLVM_MINGW_SHA256="72ef2b46f809888d1e50bbc3873f823af191e292b9308e9867e630e92fca06c5"
                EXTRACT_CMD="unzip -q"
                ;;
            aarch64|arm64)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-aarch64.zip"
                LLVM_MINGW_SHA256="e78fa5903e57af479c886230f29888bd97e631b32fcac296831bd3d6f04eb48c"
                EXTRACT_CMD="unzip -q"
                ;;
            armv7*|arm)
                LLVM_MINGW_FILE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-armv7.zip"
                LLVM_MINGW_SHA256="56452f6db9ee0d055218451869e17b1b3a0e4c09561c1a18307678d18104dfa9"
                EXTRACT_CMD="unzip -q"
                ;;
            *)
                echo "Unsupported Windows architecture: $HOST_ARCH"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Unsupported OS: $HOST_OS"
        exit 1
        ;;
esac

echo "Installing LLVM-MinGW for $HOST_OS-$HOST_ARCH -> $TARGET"

# Download and verify
wget -O /tmp/llvm-mingw-archive "${BASE_URL}/${LLVM_MINGW_FILE}"
echo "${LLVM_MINGW_SHA256}  /tmp/llvm-mingw-archive" | sha256sum -c -

# Extract to /opt
mkdir -p /opt
cd /opt
$EXTRACT_CMD /tmp/llvm-mingw-archive

# Create symlink
EXTRACTED_DIR=$(ls -d /opt/llvm-mingw-${LLVM_MINGW_VERSION}* | head -1)
ln -sf "$(basename "$EXTRACTED_DIR")" /opt/llvm-mingw

# Clean up
rm /tmp/llvm-mingw-archive

echo "LLVM-MinGW installed to /opt/llvm-mingw"
