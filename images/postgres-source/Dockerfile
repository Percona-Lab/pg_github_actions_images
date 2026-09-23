# syntax=docker/dockerfile:1
#
# Tier 2 - PostgreSQL already configured, built and installed.
#
# This is where the time goes today: 95-170s per job, in 19 of ~31 jobs, plus
# 159s in Check/Format which compiles all of PostgreSQL purely to obtain
# pgindent, pg_bsd_indent, find_typedef and perltidyrc.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_REPO
ARG PG_REF
ARG PG_BUILD_TYPE
ARG CC=gcc

# build-postgres.sh honours PG_SOURCE_DIR; without it the script would derive
# the tree from its own location, which only matches the runner's workspace
# layout ($GITHUB_WORKSPACE/src + $GITHUB_WORKSPACE/postgres), not the image's.
ENV PG_SOURCE_DIR=/opt/postgres

RUN git clone --depth 1 --branch "${PG_REF}" "${PG_REPO}" "${PG_SOURCE_DIR}" \
 && rm -rf "${PG_SOURCE_DIR}/.git"

# Reuses pg_stat_monitor's own build-postgres.sh so configure flags cannot drift
# from what CI would have produced. GITHUB_PATH only exists on a runner; the
# script appends to it unconditionally, so point it somewhere harmless.
RUN GITHUB_PATH=/dev/null CC="${CC}" \
      /opt/src/.github/scripts/build-postgres.sh "${PG_BUILD_TYPE}"

# pg_bsd_indent is a build artifact and would not survive `make clean`, but
# run-pgindent.sh needs it. Install it first, then reclaim the object files.
#
# It is only present from PostgreSQL 16 onward - before that it lived in its own
# repository - so the install is conditional. Nothing is lost on 14/15: those
# images serve the build/test matrix, while the only consumer of pg_bsd_indent
# is pg_stat_monitor's Check/Format job, which runs on psp-18.
#
# `make clean` only removes build output - src/tools/{pgindent,find_typedef,
# perlcheck} and src/test/perl are checked-in sources and survive, which is what
# dump-typedefs.sh, run-pgindent.sh and run-pgperltidy.sh actually depend on.
RUN if [ -d "${PG_SOURCE_DIR}/src/tools/pg_bsd_indent" ]; then \
        make -C "${PG_SOURCE_DIR}/src/tools/pg_bsd_indent" install; \
    fi \
 && make -C "${PG_SOURCE_DIR}" clean

ENV PATH=/usr/local/pgsql/bin:$PATH
