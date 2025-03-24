# PGBouncer image

## Build Arguments

| Variable | Default | Description |
| --- | --- | --- |
| `USER` | `pgbouncer` | The user as which to run PGBouncer. |
| `PGBOUNCER_VERSION` | (see `Dockerfile`) | The version of the PGBouncer package to install. |
| `PGCLIENT_VERSION` | (see `Dockerfile`) | The version of the PostgreSQL client package to install. |

## Environment Environment

| Variable | Default | Description |
| --- | --- | --- |
| `USER` | (the value of the build argument of the same name) | The user as which to run PGBouncer. |
| `CONFIG_FILE` | `/etc/pgbouncer/pgbouncer.ini` | The path to PGBouncer's configuration file. |
| `USERLIST_PATH` | `/etc/pgbouncer/userlist.txt` | The default path to PGBouncer's list of users. If left unpopulated, we will try to populate it using Drupal-y environment variables. |
| `DRUPAL_DB_USER` | (none) | A user name to accept inbound and forward to the backend. |
| `DRUPAL_DB_PASSWORD` | (none) | A password associated with the given user. |
| `PGHOST` | (none) | PostgreSQL host for connection test. |
| `PGDATABASE` | (none) | PostgreSQL DB name for connection test. |
| `PGUSER` | (none) | PostgreSQL user for connection test. |
| `PGPASSWORD` | (none) | PostgreSQL user for connection test. |
