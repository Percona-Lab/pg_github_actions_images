# syntax=docker/dockerfile:1
#
# Tier 1 - INTERNAL BUILD BASE. No CI job runs on this image.
#
# Every containerised job consumes either postgres-source (PostgreSQL already
# built) or pgdg/psp (PostgreSQL from packages). This layer exists so the ~28
# postgres-source variants, which build on separate runners with cold Docker
# caches, share one copy of the 30-package dev dependency set instead of
# installing and storing it 28 times over.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN /opt/src/.github/scripts/ubuntu-deps.sh dev \
 && rm -rf /var/lib/apt/lists/*

# clang: source images are built with both gcc and clang.
# sanitizers.yml hardcodes ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-14.
# Ubuntu 22.04 ships exactly that path; newer releases ship a different major,
# so alias it rather than let the sanitizer silently lose symbolisation.
RUN apt-get update \
 && apt-get install -y --no-install-recommends clang llvm \
 && rm -rf /var/lib/apt/lists/* \
 && if [ ! -e /usr/bin/llvm-symbolizer-14 ]; then \
        ln -s "$(command -v llvm-symbolizer)" /usr/bin/llvm-symbolizer-14; \
    fi
