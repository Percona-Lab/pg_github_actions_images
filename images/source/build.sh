#!/bin/bash

set -euo pipefail

: "${PG_SOURCE_DIR:?}" "${PG_INSTALL_DIR:?}"

FLAVOR=${1:-}
PG_MAJOR=${2:-}
BUILD_TYPE=${3:-}

case "${CC:-gcc}" in
    gcc) export CXX=g++ ;;
    clang) export CXX=clang++ ;;
    *)
        echo "Unknown compiler: $CC" >&2
        echo "Use one of: gcc, clang" >&2
        exit 1
        ;;
esac

if ! [[ "$PG_MAJOR" =~ ^[0-9]+$ ]]; then
    echo "Invalid major version: $PG_MAJOR" >&2
    exit 1
fi

case "$FLAVOR" in
    pgdg)
        REPO=https://github.com/postgres/postgres.git
        BRANCH=REL_${PG_MAJOR}_STABLE
        ;;
    psp)
        REPO=https://github.com/percona/postgres.git
        BRANCH=PSP_REL_${PG_MAJOR}_STABLE
        ;;
    *)
        echo "Unknown flavor: $FLAVOR" >&2
        echo "Use one of: pgdg, psp" >&2
        exit 1
        ;;
esac

ARGS=(
    --prefix="$PG_INSTALL_DIR"
    --enable-debug
    --enable-tap-tests
    --with-openssl
    --with-libxml
    --with-libxslt
    --with-lz4
    --with-uuid=e2fs
    --with-gssapi
    --with-ldap
    --with-pam
    --with-systemd
)
INJECTION_POINTS=true

case "$BUILD_TYPE" in
    debugoptimized)
        export CFLAGS="-O2"
        ARGS+=(--enable-cassert)
        ;;
    sanitize)
        export CFLAGS="-O0 -fsanitize=address -fsanitize=undefined -fno-sanitize=function -fno-omit-frame-pointer -fno-inline-functions"
        INJECTION_POINTS=false
        ;;
    exec-backend)
        export CFLAGS="-O2"
        export CPPFLAGS="-DEXEC_BACKEND"
        ARGS+=(--enable-cassert)
        ;;
    *)
        echo "Unknown build type: $BUILD_TYPE" >&2
        echo "Use one of: debugoptimized, sanitize, exec-backend" >&2
        exit 1
        ;;
esac

if [ "$PG_MAJOR" -ge 15 ]; then
    ARGS+=(--with-zstd)
fi

if [ "$PG_MAJOR" -ge 17 ]; then
    if [ "$INJECTION_POINTS" = true ]; then
        ARGS+=(--enable-injection-points)
    fi
    ARGS+=(--with-liburing)
fi

if [ "$PG_MAJOR" -ge 18 ]; then
    # libcurl enables the OAuth client flow in libpq.
    ARGS+=(--with-libcurl --with-libnuma)
fi

# The commit is kept in .git-revision, so jobs can log what they tested against.
git clone -q --depth 1 --branch "$BRANCH" "$REPO" "$PG_SOURCE_DIR"
git -C "$PG_SOURCE_DIR" rev-parse HEAD > "$PG_SOURCE_DIR/.git-revision"
rm -rf "$PG_SOURCE_DIR/.git"

cd "$PG_SOURCE_DIR"

./configure "${ARGS[@]}"

make -s -j "$(nproc)" install-world
make -s -j "$(nproc)" -C src/test/modules install

if [ "$PG_MAJOR" -ge 16 ]; then
    make -s -C src/tools/pg_bsd_indent install
fi
