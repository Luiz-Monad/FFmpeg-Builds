#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/any-macos-any-gpl-static.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
LICENSE_FILE=""
