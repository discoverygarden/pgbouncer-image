#!/bin/sh
set -eu

EMPTY=""

if [ ! -f $USERLIST_PATH -a -n ${DRUPAL_DB_USER:-EMPTY} -a -n ${DRUPAL_DB_PASSWORD:-EMPTY} ] ; then
  cat > $USERLIST_PATH <<EOF
"$DRUPAL_DB_USER" "md5$(echo -n $DRUPAL_DB_PASSWORD$DRUPAL_DB_USER | md5sum - | cut -d" " -f1)"
EOF
fi

if [ -n ${PGHOST:-EMPTY} -a -n ${PGDATABASE:-EMPTY} -a -n ${PGUSER:-EMPTY} -a -n ${PGPASSWORD:-EMPTY} ] ; then
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
