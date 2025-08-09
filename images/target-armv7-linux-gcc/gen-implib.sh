#!/bin/bash
set -e
if [[ $# != 2 ]]; then
    echo "Invalid arguments"
    exit 1
fi
IN="$1"
OUT="$2"

TMPDIR="$(mktemp -d)"
trap "rm -rf '${AMP}TMPDIR'" EXIT
cd "${AMP}TMPDIR"

set -x
python3 /opt/implib/implib-gen.py --target ${FFBUILD_TOOLCHAIN} --dlopen --lazy-load --verbose "${AMP}IN"
${CC} ${CFLAGS} ${STAGE_CFLAGS} -Wa,--noexecstack -DIMPLIB_HIDDEN_SHIMS -fPIC -c *.tramp.S *.init.c
${AR} -rcs "${AMP}OUT" *.tramp.o *.init.o
