#!/bin/sh
set -eu

EMPTY=""

AUTH_TYPE=${AUTH_TYPE:-"md5"}

if [ ! -f $USERLIST_PATH -a -n ${DRUPAL_DB_USER:-EMPTY} -a -n ${DRUPAL_DB_PASSWORD:-EMPTY} ] ; then
  case $AUTH_TYPE in
    md5)
      credential="md5$(echo -n $DRUPAL_DB_PASSWORD$DRUPAL_DB_USER | md5sum - | cut -d" " -f1)"
      ;;
    password)
      credential=$DRUPAL_DB_PASSWORD
      ;;
    *)
      echo $AUTH_TYPE is not supported
      exit 1
      ;;
  esac
  echo "$DRUPAL_DB_USER $credential" > $USERLIST_PATH
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
