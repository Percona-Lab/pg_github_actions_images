# Tier 3 - Percona Server for PostgreSQL from the Percona apt repository.
#
# Installed from the live repository on every weekly build, so a broken or
# missing package fails here rather than in a consumer's PR.
#
# The package list looks over-broad but is not: pg_stat_monitor's
# t/032_multiple_extensions.pl loads pgaudit, set_user, pg_repack, postgis,
# postgis_raster, postgis_sfcgal and postgis_tiger_geocoder. It self-skips
# unless `pg_config --version` contains "percona", so this image is the only
# path that exercises it. Expect a large image.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG PG_MAJOR

# From 18 on the JIT provider is a separate package, which is only a Recommends.
#
# The packages are built on postgresql-common, which would otherwise initdb a
# `main` cluster at install time. Jobs create their own clusters.
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
