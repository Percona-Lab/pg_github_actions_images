# pg_github_actions_images

Prebuilt CI images for Percona's PostgreSQL Team projects

## Images

Published to `ghcr.io/percona-lab/pg_github_actions_images/<name>:<tag>`.

| Image | Tags | Description |
|---|---|---|
| `postgres-source` | `<flavor>-<major>-<compiler>-<build_type>-ubuntu<ubuntu>` | Source build of PostgreSQL |
| `psp` | `<major>-ubuntu<ubuntu>` (14–18) | Percona Server for PostgreSQL installed from packages |
| `pgdg` | `<major>-ubuntu<ubuntu>` (14–18) | PostgreSQL installed from PGDG packages |
| `base` | `<ubuntu>` (22.04, 24.04) | Base layer |
| `base-dev` | `<ubuntu>` (22.04, 24.04) | Base layer for source builds |

`flavor` is `pgdg` (`postgres/postgres@REL_<major>_STABLE`) or `psp`
(`percona/postgres@PSP_REL_<major>_STABLE`).

## Usage

Set `container:` on the job. Note three things:

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
