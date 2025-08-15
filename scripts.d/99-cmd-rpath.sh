#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_enabled() {
    [[ $TARGET == *-linux-* ]] && return $FFBUILD_TRUE
    return $FFBUILD_FALSE
}
ffbuild_dockerfinal() {
    return $FFBUILD_TRUE
}

ffbuild_dockerdl() {
    true
}

ffbuild_dockerlayer() {
    return $FFBUILD_TRUE
}

ffbuild_dockerstage() {
    return $FFBUILD_TRUE
}

ffbuild_dockerbuild() {
    return $FFBUILD_TRUE
}

ffbuild_ldexeflags() {
    echo '-pie'

    if [[ $VARIANT == *shared* ]]; then
        # Can't escape escape hell
        echo -Wl,-rpath='\\\\\\\$\\\$ORIGIN'
        echo -Wl,-rpath='\\\\\\\$\\\$ORIGIN/../lib'
    fi
}
