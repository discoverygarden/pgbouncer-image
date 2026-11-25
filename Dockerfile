ARG USER=pgbouncer

# Built from source: Alpine 3.24 (and edge) only package 1.25.2, which predates
# the fixes in 1.26.0/1.26.1: CVE-2026-19888, CVE-2026-6668, CVE-2026-6669,
# CVE-2026-107348, CVE-2026-107349 and CVE-2026-107350 (SCRAM impersonation).
# Not tracked by Renovate: bump the version and checksum together by hand, and
# drop the source build once Alpine packages >= 1.26.1.
ARG PGBOUNCER_VERSION=1.26.1
ARG PGBOUNCER_SHA256=00886a2994b4844cd37110970df777772cfc42a74c400522c82fba509a3f42d9
# renovate: datasource=repology depName=alpine_3_24/postgresql16-client versioning=loose
ARG PGCLIENT_VERSION=16.16-r0

FROM alpine:3.24.4 AS build

ARG PGBOUNCER_VERSION
ARG PGBOUNCER_SHA256

RUN <<-'EOS'
set -ex
apk add --no-cache build-base c-ares-dev libevent-dev openssl-dev
wget -O /tmp/pgbouncer.tar.gz \
  "https://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz"
echo "${PGBOUNCER_SHA256}  /tmp/pgbouncer.tar.gz" | sha256sum -c -
tar -xzf /tmp/pgbouncer.tar.gz -C /tmp
cd "/tmp/pgbouncer-${PGBOUNCER_VERSION}"
./configure --prefix=/usr --disable-debug
# Binary only: the man pages need pandoc, which we don't ship.
make -j"$(nproc)" pgbouncer
install -D -m 755 pgbouncer /out/usr/bin/pgbouncer
install -D -m 644 etc/pgbouncer.ini /out/etc/pgbouncer/pgbouncer.ini
install -d /out/var/log/pgbouncer
EOS

FROM alpine:3.24.4

ARG PGCLIENT_VERSION

# XXX: postgresql16-client is used independent of the underlying database. This
# should be fine, since we really only want it for its `pg_isready` script.
RUN <<-'EOS'
set -ex
apk add --no-cache \
  c-ares \
  libevent \
  libssl3 \
  postgresql16-client="${PGCLIENT_VERSION}"
EOS

COPY --from=build --link /out/ /

EXPOSE 6432

COPY --link rootfs /

ENV CONFIG_FILE=/etc/pgbouncer/pgbouncer.ini
ENV USERLIST_PATH=/etc/pgbouncer/userlist.txt

ARG USER
ENV USER=$USER
RUN adduser -S $USER

ENTRYPOINT ["/opt/entry-point.sh"]
