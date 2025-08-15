#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    return $FFBUILD_TRUE
}

ffbuild_dockerdl() {
    true
}

ffbuild_dockerbuild() {
    return $FFBUILD_TRUE
}
