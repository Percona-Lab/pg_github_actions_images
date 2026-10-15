ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bison \
      clang \
      cmake \
      docbook-xml \
      docbook-xsl \
      flex \
      lcov \
      libcurl4-openssl-dev \
      libicu-dev \
      libldap2-dev \
      liblz4-dev \
      libnuma-dev \
      libpam0g-dev \
      libreadline-dev \
      libssl-dev \
      libsystemd-dev \
      liburing-dev \
      libxml2-dev \
      libxml2-utils \
      libxslt1-dev \
      libzstd-dev \
      llvm \
      lz4 \
      mawk \
      meson \
      ninja-build \
      uuid-dev \
      xsltproc \
      zlib1g-dev \
      zstd \
 && rm -rf /var/lib/apt/lists/*
