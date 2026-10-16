# pg_github_actions_images

Prebuilt CI images for Percona's PostgreSQL Team projects

## Images

Published to `ghcr.io/percona-lab/pg_github_actions_images/<name>:<tag>`.

| Image | Tags | Description |
|---|---|---|
| `postgres-source` | `<flavor>-<major>-<compiler>-<build_type>-ubuntu<ubuntu>` | Source build of PostgreSQL |
| `psp` | `<major>-ubuntu<ubuntu>` (14–18) | Percona Server for PostgreSQL installed from packages |
| `pgdg` | `<major>-ubuntu<ubuntu>` (14–18) | PostgreSQL installed from PGDG packages |
| `base` | `<ubuntu>` (24.04) | Base layer |
| `base-dev` | `<ubuntu>` (24.04) | Base layer for source builds |

`flavor` is `pgdg` (`postgres/postgres@REL_<major>_STABLE`) or `psp`
(`percona/postgres@PSP_REL_<major>_STABLE`). `build_type` is
`debugoptimized`, `exec-backend` (gcc only) or `sanitize` (only
`psp-18-clang-sanitize-ubuntu24.04`).

All images are built for amd64. The following are also built for arm64, under
the same tags, for the ARM jobs (`runs-on: ubuntu-24.04-arm`):

- `base` and `base-dev`: `24.04`
- `postgres-source`: `psp-<16–19>-<gcc|clang>-debugoptimized-ubuntu24.04`
- `psp`: `<17|18>-ubuntu24.04`

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: ghcr.io/percona-lab/pg_github_actions_images/postgres-source:psp-18-gcc-debugoptimized-ubuntu24.04
```

Set `container:` on the job. Note four things:

1. **Steps run as the unprivileged `ci` user, not root**, because PostgreSQL
   refuses to run as root. `ci` has UID 1001, the same as the `runner` user on
   GitHub-hosted runners, so it owns the checkout and nothing needs a `chown`.
   Use `sudo` for anything that needs root, such as `apt-get` or installing
   into the PGDG/Percona package paths; it is passwordless.

2. **The PostgreSQL source tree lives at `/opt/postgres` and the installation
   at `/usr/local/pgsql`**, not next to the checkout. `PG_SOURCE_DIR` and
   `PG_INSTALL_DIR` are set in the image; a project's CI scripts should honour
   them, so that `pg_config`, `pgindent`, `find_typedef` and `perltidyrc`
   resolve correctly.

3. **The `source` tree keeps its object files**, so `make
   installcheck-world` (pg_tde's "PSP with TDE" job) or an in-tree contrib build
   can run in `/opt/postgres` without recompiling PostgreSQL first.

4. **Jobs that start PostgreSQL need `options: --init`.** The job container's
   main process does not reap orphaned processes, so a postmaster that a test
   kills stays a zombie, its PID stays taken, and restarting the node fails.
