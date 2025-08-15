#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/any-windows-any-gpl-shared.sh
FF_CONFIGURE="--enable-nonfree $FF_CONFIGURE"
