# pg_github_actions_images

Prebuilt CI images for Percona's PostgreSQL extensions, consumed by
[`percona/pg_stat_monitor`](https://github.com/percona/pg_stat_monitor) and
[`percona/pg_tde`](https://github.com/percona/pg_tde).

Both projects rebuilt their environment from scratch in every CI job: purging
the runner's preinstalled PostgreSQL, apt-installing the same dependency list,
and — in most jobs — cloning and compiling PostgreSQL before building the
extension. That was roughly **68 of 194 runner-minutes per pg_stat_monitor PR**,
about 35% of total CI time. These images move that work off the critical path.

## Images

Published to `ghcr.io/percona-lab/pg_github_actions_images/<name>:<tag>`.

| Image | Tags | Used by |
|---|---|---|
| `postgres-source` | `<flavor>-<major>-<compiler>-<build_type>` | jobs that need PostgreSQL built from source |
| `psp` | `<major>` (14–18) | jobs testing against Percona Server for PostgreSQL packages |
| `pgdg` | `<major>` (14–18) | jobs testing against PGDG packages |
| `pg-build-base` | `<ubuntu>` (22.04, 24.04) | base layer for `psp`/`pgdg` |
| `pg-build-dev` | `internal-<ubuntu>` | **internal build base only** |

`flavor` is `community` (`postgres/postgres@REL_<major>_STABLE`) or `psp`
(`percona/postgres@PSP_REL_<major>_STABLE`).

**No CI job should run on `pg-build-dev`.** It exists so the ~28
`postgres-source` variants, which build on separate runners with cold Docker
caches, share one copy of the dev dependency set instead of installing and
storing it 28 times.

Each `postgres-source` tag is published twice: a moving tag that PRs consume,
and an immutable `...-<upstream-sha>` tag for pinning or rollback.

## Using them

Set `container:` on the job. Note two things:

1. **Container jobs run as root, and PostgreSQL refuses to run as root.** Give
   the workspace to the image's unprivileged `ci` user and wrap the test step:

   ```yaml
   - name: Hand the workspace to the unprivileged user
     run: chown -R ci:ci "$GITHUB_WORKSPACE"
   - name: Run tests
     run: run-as-ci ./run-my-tests.sh
   ```

2. **The PostgreSQL source tree lives at `/opt/postgres`**, not next to the
   checkout. `PG_SOURCE_DIR` is set in the image and the pg_stat_monitor scripts
   honour it, so `pgindent`, `find_typedef` and `perltidyrc` resolve correctly.

## Dependencies are not defined here

The Dockerfiles deliberately do **not** carry their own package lists. They
`COPY` and run pg_stat_monitor's own `.github/scripts/ubuntu-deps.sh`,
`install-postgresql.sh` and `build-postgres.sh`, so those scripts stay the
single source of truth and cannot drift from what CI needs.

This is also why there is no separate "freshness" job anywhere: the nightly
build here *is* the freshness check. It clones the upstream branch tips and
installs from the live Percona and PGDG repositories, so an upstream compile
break or a broken package fails this build.

**That makes `build-images.yml` load-bearing.** Its failures no longer surface
as a red PR check in the consuming repositories — if the nightly build breaks
silently, pg_stat_monitor and pg_tde keep passing against stale images. The
workflow posts to Slack on scheduled-run failure; it needs `SLACK_WEBHOOK_URL`
set in this repository.

## Rebuilding

Nightly at 02:00 UTC, on pushes to `main` that touch `images/**`, and on demand
via `workflow_dispatch` (which takes a `pgsm_ref` input to pull the scripts from
a branch — useful when changing a dependency list and the images together).
