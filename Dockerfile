ARG USER=pgbouncer

# renovate: datasource=repology depName=alpine_3_21/pgbouncer versioning=loose
ARG PGBOUNCER_VERSION=1.23.1-r0
# renovate: datasource=repology depName=alpine_3_21/postgresql16-client versioning=loose
ARG PGCLIENT_VERSION=16.8-r0

FROM alpine:3.21.3

ARG USER
ARG PGBOUNCER_VERSION
ARG PGCLIENT_VERSION

RUN adduser -S $USER

RUN <<-'EOS'
set -ex
apk add --no-cache \
  pgbouncer="${PGBOUNCER_VERSION}" \
  postgresql16-client="${PGCLIENT_VERSION}"
EOS

EXPOSE 6432

COPY --link rootfs /

ENV USER=$USER
ENV CONFIG_FILE=/etc/pgbouncer/pgbouncer.ini
ENV USERLIST_PATH=/etc/pgbouncer/userlist.txt
ENTRYPOINT ["/opt/entry-point.sh"]
