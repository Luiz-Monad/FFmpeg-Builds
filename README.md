# FFmpeg Static Auto-Builds

Static Windows (x86_64) and Linux (x86_64) Builds of ffmpeg master and latest release branch.

Windows builds are targetting Windows 7 and newer, provided UCRT is installed.
The minimum supported version is Windows 10 22H2, no guarantees on anything older.

Linux builds are targetting RHEL/CentOS 8 (glibc-2.28 + linux-4.18) and anything more recent.

## Auto-Builds

Builds run daily at 12:00 UTC (or GitHubs idea of that time) and are automatically released on success.

**Auto-Builds run ONLY for the linux host and the targets bellow. There are no 32 bits auto-builds, though you can produce win32 builds yourself following the instructions below.**

### Release Retention Policy

- The last build of each month is kept for two years.
- The last 14 daily builds are kept.
- The special "latest" build floats and provides consistent URLs always pointing to the latest build.

## Package List

For a list of included dependencies check the scripts.d directory.
Every file corresponds to its respective package.

## How to make a build

### Prerequisites

* bash
* docker

### Build Image

* `./makeimage.sh runner target variant [addin [addin] [addin] ...]`

### Build FFmpeg

* `./build.sh runner target variant [addin [addin] [addin] ...]`

On success, the resulting zip file will be in the `artifacts` subdir.

### Targets, Variants and Addins

Available targets:
* aarch64-ios-clang
* aarch64-ios-xcode
* aarch64-macos-clang
* aarch64-macos-xcode
* x86_64-macos-clang
* x86_64-macos-xcode
* aarch64-android-clang
* aarch64-ios-cross-clang
* aarch64-linux-clang
* aarch64-linux-gcc
* aarch64-macos-cross-clang
* aarch64-windows-cross-clang
* armv7-android-clang
* armv7-linux-clang
* armv7-linux-gcc
* x86_64-android-clang
* x86_64-linux-clang
* x86_64-linux-gcc
* x86_64-macos-cross-clang
* x86_64-windows-cross-clang
* aarch64-windows-clang
* aarch64-windows-msvc
* x86_64-windows-clang
* x86_64-windows-msvc

The linuxarm64 target will not build some dependencies due to lack of arm64 (aarch64) architecture support or cross-compiling restrictions.

* `davs2` and `xavs2`: aarch64 support is broken.
* `libmfx` and `libva`: Library for Intel QSV, so there is no aarch64 support.

Available variants:
* `gpl` Includes all dependencies, even those that require full GPL instead of just LGPL.
* `lgpl` Lacking libraries that are GPL-only. Most prominently libx264 and libx265.
* `nonfree` Includes fdk-aac in addition to all the dependencies of the gpl variant.
* `gpl-shared` Same as gpl, but comes with the libav* family of shared libs instead of pure static executables.
* `lgpl-shared` Same again, but with the lgpl set of dependencies.
* `nonfree-shared` Same again, but with the nonfree set of dependencies.

All of those can be optionally combined with any combination of addins:
* `7.0`/`7.1`/``8.0` to build from the respective release branch instead of master.
* `debug` to not strip debug symbols from the binaries. This increases the output size by about 250MB.
* `lto` build all dependencies and ffmpeg with -flto=auto (HIGHLY EXPERIMENTAL, broken for Windows, sometimes works for Linux)
