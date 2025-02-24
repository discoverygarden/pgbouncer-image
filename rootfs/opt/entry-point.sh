#!/bin/sh
set -eu

if [ ! -f $USERLIST_PATH ] ; then
  cat > $USERLIST_PATH <<EOF
"$DRUPAL_DB_USER" "md5$(echo -n $DRUPAL_DB_PASSWORD$DRUPAL_DB_USER | md5sum - | cut -d" " -f1)"
EOF
fi

if [ -n "$PGHOST" -a -n "$PGDATABASE" -a -n "$PGUSER" -a -n "$PGPASSWORD" ] ; then
  ATTEMPTS=0
  while ! pg_isready ; do
    ATTEMPTS=$(($ATTEMPTS + 1))
    if [ $ATTEMPTS -gt 3 ] ; then
      echo "Failed to connect after multiple attempts."
      exit 1
    else
      sleep 1
    fi
  done
else
  echo "Lacking PG* vars to more generally test the DB connection."
fi
exec pgbouncer --user=$USER $CONFIG_FILE
