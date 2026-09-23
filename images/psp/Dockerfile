# syntax=docker/dockerfile:1
#
# Tier 3 - Percona Server for PostgreSQL from the Percona apt repository.
#
# The package list in install-postgresql.sh looks over-broad but is not:
# t/032_multiple_extensions.pl loads pgaudit, set_user, pg_repack, postgis,
# postgis_raster, postgis_sfcgal and postgis_tiger_geocoder. It self-skips
# unless `pg_config --version` contains "percona", so this image is the only
# path that exercises it. Expect a large image; measure pull time before
# converting the whole psp matrix.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_MAJOR

ENV DEBIAN_FRONTEND=noninteractive

# clang is needed here but not in pgdg: the ARM matrix builds psp with both
# gcc and clang.
RUN apt-get update \
 && apt-get install -y --no-install-recommends clang \
 && /opt/src/.github/scripts/install-postgresql.sh psp "${PG_MAJOR}" \
 && rm -rf /var/lib/apt/lists/*
