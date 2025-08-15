#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/any-macos-any-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
