#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Invalid Arguments"
    exit -1
fi

TARGET="$1"
VARIANT="$2"
shift 2

if ! [[ -f "variants/${TARGET}-${VARIANT}.sh" ]]; then
    echo "Invalid target/variant"
    exit -1
fi

LICENSE_FILE="COPYING.LGPLv2.1"

ADDINS=()
ADDINS_STR=""
while [[ "$#" -gt 0 ]]; do
    if ! [[ -f "addins/${1}.sh" ]]; then
        echo "Invalid addin: $1"
        exit -1
    fi

    ADDINS+=( "$1" )
    ADDINS_STR="${ADDINS_STR}${ADDINS_STR:+-}$1"

    shift
done

FFBUILD_TRUE=0
FFBUILD_FALSE=-1

REPO="${GITHUB_REPOSITORY:-Luiz-Monad/FFmpeg-Builds}"
REPO="${REPO,,}"
REGISTRY="${REGISTRY_OVERRIDE:-ghcr.io}"
BASE_IMAGE="${REGISTRY}/${REPO}/base:latest"
TARGET_IMAGE="${REGISTRY}/${REPO}/base-${TARGET}:latest"
IMAGE="${REGISTRY}/${REPO}/${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}:latest"

ffbuild_ffver() {
    case "$ADDINS_STR" in
    *7.0*)
        echo 700
        ;;
    *7.1*)
        echo 701
        ;;
    *8.0*)
        echo 800
        ;;
    *)
        echo 99999999
        ;;
    esac
}


ffbuild_dockerstage() {
    if [[ -n "$SELFCACHE" ]]; then
        to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=${SELFCACHE},dst=/cache.tar.xz run_stage /stage.sh"
    else
        to_df "RUN --mount=src=${SELF},dst=/stage.sh run_stage /stage.sh"
    fi
}

ffbuild_dockerlayer() {
    to_df "COPY --link --from=${SELFLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
}

ffbuild_dockerfinal() {
    to_df "COPY --link --from=${PREVLAYER} \$FFBUILD_PREFIX/. \$FFBUILD_PREFIX"
}

ffbuild_configure() {
    return $FFBUILD_TRUE
}

ffbuild_unconfigure() {
    return $FFBUILD_TRUE
}

ffbuild_cflags() {
    return $FFBUILD_TRUE
}

ffbuild_uncflags() {
    return $FFBUILD_TRUE
}

ffbuild_cxxflags() {
    return $FFBUILD_TRUE
}

ffbuild_uncxxflags() {
    return $FFBUILD_TRUE
}

ffbuild_ldexeflags() {
    return $FFBUILD_TRUE
}

ffbuild_unldexeflags() {
    return $FFBUILD_TRUE
}

ffbuild_ldflags() {
    return $FFBUILD_TRUE
}

ffbuild_unldflags() {
    return $FFBUILD_TRUE
}

ffbuild_libs() {
    return $FFBUILD_TRUE
}

ffbuild_unlibs() {
    return $FFBUILD_TRUE
}
