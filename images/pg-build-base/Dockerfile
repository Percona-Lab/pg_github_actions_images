# syntax=docker/dockerfile:1
#
# Tier 0 - common CI base.
#
# Deliberately contains NO postgresql*/libpq* packages. That is the point: the
# GitHub-hosted runner images ship PostgreSQL preinstalled, which is why every
# job currently starts with `sudo apt purge postgresql* libpq*`. Starting from a
# clean base removes that step entirely.
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Etc/UTC

# ubuntu-deps.sh and install-postgresql.sh invoke apt through `sudo`, and sudo
# sanitises the environment - so the DEBIAN_FRONTEND above does NOT reach them.
# Persist the choice in the debconf database instead, where it survives sudo,
# and pre-answer tzdata so nothing has anything to ask. Without this, installing
# the dev dependency set on 22.04 blocks forever on tzdata's "Geographic area:"
# prompt.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
 && ln -snf /usr/share/zoneinfo/Etc/UTC /etc/localtime \
 && echo Etc/UTC > /etc/timezone

# Bootstrap only. sudo must exist before ubuntu-deps.sh runs (it calls sudo);
# git + ca-certificates are required by actions/checkout; util-linux provides
# setpriv for run-as-ci.
#
# file(1) matters more than it looks: PostgreSQL's find_perl_files (used by
# run-pgperltidy.sh) shells out to it to pick up executable perl scripts that
# have no .pl/.pm extension. Without it that branch silently matches nothing and
# pgperltidy passes vacuously.
#
# clang is deliberately NOT here: it drags in ~210MB of LLVM, and the only
# consumers of this tier that need it are the psp images (the ARM matrix builds
# psp with both gcc and clang). pgdg is gcc-only and stays lean, which matters
# because Tier 3 only saves 35-44s per job before pull cost.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      gcc \
      git \
      gnupg \
      locales \
      lsb-release \
      make \
      sudo \
      util-linux \
 && rm -rf /var/lib/apt/lists/*

# The dependency list is NOT duplicated here on purpose. The image runs
# pg_stat_monitor's own ubuntu-deps.sh so that script stays exercised by the
# nightly build and cannot drift away from what CI actually needs.
COPY pgsm/.github/scripts/ /opt/src/.github/scripts/
RUN /opt/src/.github/scripts/ubuntu-deps.sh \
 && rm -rf /var/lib/apt/lists/*

# PostgreSQL refuses to run as root; container jobs always start as root.
RUN useradd --create-home --uid 1001 --shell /bin/bash ci \
 && echo 'ci ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ci \
 && echo 'Defaults env_keep += "DEBIAN_FRONTEND TZ"' >> /etc/sudoers.d/ci \
 && chmod 0440 /etc/sudoers.d/ci
COPY images/common/run-as-ci /usr/local/bin/run-as-ci
RUN chmod 0755 /usr/local/bin/run-as-ci
