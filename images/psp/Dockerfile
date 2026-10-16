ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_MAJOR

RUN install -d /etc/postgresql-common/createcluster.d \
 && echo 'create_main_cluster = false' \
      > /etc/postgresql-common/createcluster.d/no-main-cluster.conf \
 && curl -fsSL -o /tmp/percona-release.deb \
      https://repo.percona.com/apt/percona-release_latest.generic_all.deb \
 && apt-get install -y --no-install-recommends /tmp/percona-release.deb \
 && rm /tmp/percona-release.deb \
 && percona-release setup "ppg-${PG_MAJOR}" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      "percona-postgresql-${PG_MAJOR}" \
      $([ "${PG_MAJOR}" -ge 18 ] && echo "percona-postgresql-${PG_MAJOR}-jit") \
      percona-postgresql-contrib \
      percona-postgresql-server-dev-all \
      percona-pgpool2 \
      libpgpool2 \
      "percona-postgresql-${PG_MAJOR}-pgaudit" \
      "percona-postgresql-${PG_MAJOR}-repack" \
      "percona-pgaudit${PG_MAJOR}-set-user" \
      "percona-postgresql-${PG_MAJOR}-postgis-3" \
      "percona-postgresql-${PG_MAJOR}-postgis-3-scripts" \
      percona-postgresql-postgis-scripts \
      percona-postgresql-postgis \
      percona-postgis \
 && rm -rf /var/lib/apt/lists/*

# Jobs run as the unprivileged user
USER ci
