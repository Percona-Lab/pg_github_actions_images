# syntax=docker/dockerfile:1
#
# Tier 3 - PostgreSQL from the PGDG apt repository.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_MAJOR

ENV DEBIAN_FRONTEND=noninteractive

# Running the real install-postgresql.sh keeps it exercised nightly against the
# live repository, which is what makes a separate freshness job unnecessary.
RUN /opt/src/.github/scripts/install-postgresql.sh pgdg "${PG_MAJOR}" \
 && rm -rf /var/lib/apt/lists/*
