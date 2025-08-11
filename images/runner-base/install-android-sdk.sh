#!/bin/bash
set -xe

# Use environment variables with fallback defaults
VERSION_SDK=${VERSION_SDK:-13114758}
VERSION_NDK=${VERSION_NDK:-28.1.13356709}
ANDROID_SDK_HOME=${ANDROID_SDK_HOME:-"/opt/android-sdk"}

# Installing basic software
apt-get --allow-releaseinfo-change update 
apt-get install -y --no-install-recommends \
    ninja-build \
    build-essential \
    openjdk-17-jdk-headless \
    curl \
    unzip \
    cmake \
    meson \
    bash \
    nasm \
    pkg-config \
    make \
    git

apt-get clean
rm -rf /var/lib/apt/lists/*

# Download the Android SDK
TMP=/tmp-sdk
mkdir -p $TMP
curl https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK}_latest.zip --output $TMP/android-sdk.zip

# Unzip it
mkdir -p "${ANDROID_SDK_HOME}"
unzip -qq $TMP/android-sdk.zip -d "${ANDROID_SDK_HOME}"

# Installing components through the Android SDK
installAndroidComponent() { 
  yes | "${ANDROID_SDK_HOME}/cmdline-tools/bin/sdkmanager" --sdk_root="${ANDROID_SDK_HOME}" "$1" > /dev/null; 
} 
installAndroidComponent "ndk;${VERSION_NDK}"

# Clean-up
rm -rf $TMP
