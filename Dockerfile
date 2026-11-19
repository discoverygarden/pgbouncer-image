ARG USER=pgbouncer

# renovate: datasource=repology depName=alpine_3_21/pgbouncer versioning=loose
ARG PGBOUNCER_VERSION=1.23.1-r0
# renovate: datasource=repology depName=alpine_3_21/postgresql16-client versioning=loose
ARG PGCLIENT_VERSION=16.14-r0

FROM alpine:3.21.3

ARG PGBOUNCER_VERSION
ARG PGCLIENT_VERSION

# XXX: postgresql16-client is used independent of the underlying database. This
# should be fine, since we really only want it for its `pg_isready` script.
RUN <<-'EOS'
set -ex
apk add --no-cache \
  pgbouncer="${PGBOUNCER_VERSION}" \
  postgresql16-client="${PGCLIENT_VERSION}"
EOS

EXPOSE 6432

COPY --link rootfs /

ENV CONFIG_FILE=/etc/pgbouncer/pgbouncer.ini
ENV USERLIST_PATH=/etc/pgbouncer/userlist.txt

ARG USER
ENV USER=$USER
RUN adduser -S $USER

ENTRYPOINT ["/opt/entry-point.sh"]

# --------------------------------------
# Package manifest: prints every installed package to the build log as
#   DGI-PKG <arch> <type> <name> <version>
# so security checks can read versions from the image build's job log.
# Keep this as the last step of the final stage.
# --------------------------------------
RUN a=$(uname -m); \
  awk -v a="$a" '/^P:/{p=substr($0,3)} /^V:/{print "DGI-PKG", a, "apk", p, substr($0,3)}' /lib/apk/db/installed; \
  true
