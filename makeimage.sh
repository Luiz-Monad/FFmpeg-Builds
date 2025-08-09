#!/bin/bash
set -xeo pipefail
cd "$(dirname "$0")"
source util/vars.sh

# Use the same buildkit config as in CI
BUILDKIT_CFG=".github/buildkit.toml"
if [[ ! -f "$BUILDKIT_CFG" ]]; then
    echo "Missing $BUILDKIT_CFG"
    exit 1
fi

docker buildx inspect ffbuilder &>/dev/null || docker buildx create \
    --bootstrap \
    --name ffbuilder \
    --config "$BUILDKIT_CFG" \
    --driver docker \
    --driver-opt network=host \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1

if [[ -z "$QUICKBUILD" ]]; then
    # Step 1: Build base image
    BASE_IMAGE_TARGET="${PWD}/.cache/images/target"
    if [[ ! -d "${BASE_IMAGE_TARGET}" ]]; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=".cache/${BASE_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=".cache/${BASE_IMAGE/:/_}" \
            --load --tag "${BASE_IMAGE}" \
            "images/target"
        mkdir -p "${BASE_IMAGE_TARGET}"
        docker image save "${BASE_IMAGE}" | tar -x -C "${BASE_IMAGE_TARGET}"
    fi

    # Step 2: Build target base image
    IMAGE_TARGET="${PWD}/.cache/images/target-${TARGET}"
    if [[ ! -d "${IMAGE_TARGET}" ]]; then
        docker buildx --builder ffbuilder build \
            --cache-from=type=local,src=".cache/${TARGET_IMAGE/:/_}" \
            --cache-to=type=local,mode=max,dest=".cache/${TARGET_IMAGE/:/_}" \
            --build-arg GH_REPO="${REGISTRY}/${REPO}" \
            --build-context "${BASE_IMAGE}=oci-layout://${BASE_IMAGE_TARGET}" \
            --load --tag "${TARGET_IMAGE}" \
            "images/target-${TARGET}"
        mkdir -p "${IMAGE_TARGET}"
        docker image save "${TARGET_IMAGE}" | tar -x -C "${IMAGE_TARGET}"
    fi

    CONTEXT_SRC="oci-layout://${IMAGE_TARGET}"
else
    # QUICKBUILD path: use registry image directly
    CONTEXT_SRC="docker-image://${TARGET_IMAGE}"
fi

# Step 3: Prepare variant-specific Dockerfile and assets
./download.sh
./generate.sh "$RUNNER" "$TARGET" "$VARIANT" "${ADDINS[@]}"

# Step 4: Build variant image
docker buildx --builder ffbuilder build \
    --cache-from=type=local,src=".cache/${IMAGE/:/_}" \
    --cache-to=type=local,mode=max,dest=".cache/${IMAGE/:/_}" \
    --build-context "${TARGET_IMAGE}=${CONTEXT_SRC}" \
    --load --tag "$IMAGE" .

# Step 5: Cleanup
if [[ -z "$NOCLEAN" ]]; then
    docker buildx rm -f ffbuilder || true
    rm -rf .cache/images
fi
