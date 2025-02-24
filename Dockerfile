ARG USER=pgbouncer

FROM alpine

ARG USER

RUN adduser -S $USER

RUN <<-'EOS'
set -ex
apk add --no-cache pgbouncer postgresql-client
EOS

EXPOSE 6432

COPY --link rootfs /

ENV USER=$USER
ENV CONFIG_FILE=/etc/pgbouncer/pgbouncer.ini
ENV USERLIST_PATH=/etc/pgbouncer/userlist.txt
ENTRYPOINT ["/opt/entry-point.sh"]
