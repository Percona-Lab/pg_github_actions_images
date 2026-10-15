ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      g++ \
      gcc \
      git \
      gnupg \
      libipc-run-perl \
      libjson-perl \
      libjson-xs-perl \
      libkrb5-dev \
      libtext-trim-perl \
      locales \
      lsb-release \
      make \
      perl \
      perltidy \
      pkg-config \
      sudo \
      wget \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# Create user for CI jobs
RUN useradd --create-home --uid 1001 --shell /bin/bash ci \
 && echo 'ci ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ci \
 && chmod 0440 /etc/sudoers.d/ci
