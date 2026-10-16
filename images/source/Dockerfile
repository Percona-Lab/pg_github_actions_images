ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_FLAVOR
ARG PG_MAJOR
ARG PG_BUILD_TYPE
ARG CC=gcc
# Let target CI find source and installation directories
ENV PG_SOURCE_DIR=/opt/postgres
ENV PG_INSTALL_DIR=/usr/local/pgsql

COPY images/source/build.sh /opt/build.sh

RUN CC="${CC}" /opt/build.sh "${PG_FLAVOR}" "${PG_MAJOR}" "${PG_BUILD_TYPE}" \
 && chown -R ci:ci "${PG_SOURCE_DIR}" "${PG_INSTALL_DIR}"

ENV PATH=${PG_INSTALL_DIR}/bin:$PATH

COPY --chmod=0755 images/source/llvm-symbolizer /usr/local/bin/llvm-symbolizer
ENV ASAN_SYMBOLIZER_PATH=/usr/local/bin/llvm-symbolizer
ENV LSAN_SYMBOLIZER_PATH=/usr/local/bin/llvm-symbolizer
ENV UBSAN_SYMBOLIZER_PATH=/usr/local/bin/llvm-symbolizer

# Jobs run as the unprivileged user
USER ci
