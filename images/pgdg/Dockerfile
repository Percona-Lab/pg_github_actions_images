ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_MAJOR

RUN install -d /usr/share/postgresql-common/pgdg /etc/postgresql-common/createcluster.d \
 && echo 'create_main_cluster = false' \
      > /etc/postgresql-common/createcluster.d/no-main-cluster.conf \
 && curl -fsSL -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
      https://www.postgresql.org/media/keys/ACCC4CF8.asc \
 && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      "postgresql-${PG_MAJOR}" \
      $([ "${PG_MAJOR}" -ge 18 ] && echo "postgresql-${PG_MAJOR}-jit") \
      "postgresql-server-dev-${PG_MAJOR}" \
 && rm -rf /var/lib/apt/lists/*

# Jobs run as the unprivileged user
USER ci
