#!/bin/bash
#
# Build an image locally, the way build-images.yml does.
#
# The Dockerfiles run pg_stat_monitor's own .github/scripts, so the build
# context needs a checkout of it alongside images/. This script arranges that.
#
#   ./build-local.sh base
#   ./build-local.sh dev
#   ./build-local.sh source community 18 gcc debugoptimized
#   ./build-local.sh pgdg 18
#   ./build-local.sh psp 18
#
# Set PGSM_DIR to reuse an existing checkout instead of cloning.

set -euo pipefail

ROOT=$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)
UBUNTU_VERSION=${UBUNTU_VERSION:-24.04}
PREFIX=${PREFIX:-pgsm-ci}

cd "$ROOT"
if [ -n "${PGSM_DIR:-}" ]; then
    rm -rf pgsm && mkdir -p pgsm/.github
    cp -r "$PGSM_DIR/.github/scripts" pgsm/.github/scripts
elif [ ! -d pgsm ]; then
    git clone --depth 1 https://github.com/percona/pg_stat_monitor.git pgsm
fi

case "${1:-}" in
    base)
        docker build --build-arg "UBUNTU_VERSION=$UBUNTU_VERSION" \
            -f images/pg-build-base/Dockerfile \
            -t "$PREFIX/pg-build-base:$UBUNTU_VERSION" .
        ;;
    dev)
        docker build --build-arg "BASE_IMAGE=$PREFIX/pg-build-base:$UBUNTU_VERSION" \
            -f images/pg-build-dev/Dockerfile \
            -t "$PREFIX/pg-build-dev:internal-$UBUNTU_VERSION" .
        ;;
    source)
        flavor=$2; major=$3; cc=$4; build_type=$5
        if [ "$flavor" = psp ]; then
            repo=https://github.com/percona/postgres.git; ref=PSP_REL_${major}_STABLE
        else
            repo=https://github.com/postgres/postgres.git; ref=REL_${major}_STABLE
        fi
        docker build \
            --build-arg "BASE_IMAGE=$PREFIX/pg-build-dev:internal-$UBUNTU_VERSION" \
            --build-arg "PG_REPO=$repo" \
            --build-arg "PG_REF=$ref" \
            --build-arg "PG_BUILD_TYPE=$build_type" \
            --build-arg "CC=$cc" \
            -f images/postgres-source/Dockerfile \
            -t "$PREFIX/postgres-source:$flavor-$major-$cc-$build_type" .
        ;;
    pgdg|psp)
        docker build --build-arg "BASE_IMAGE=$PREFIX/pg-build-base:$UBUNTU_VERSION" \
            --build-arg "PG_MAJOR=$2" \
            -f "images/$1/Dockerfile" -t "$PREFIX/$1:$2" .
        ;;
    *)
        sed -n '3,15p' "$0"
        exit 1
        ;;
esac
