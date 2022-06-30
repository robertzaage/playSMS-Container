#!/bin/bash

MYSQL="mysql -u $DBUSER -p$DBPASS -h $DBHOST -P $DBPORT $DBNAME"

while [ ${RET:-1} -ne 0 ]; do
  sleep 3
  echo "=> Waiting for database..."
  mysql -u $DBUSER -p$DBPASS -h $DBHOST -P $DBPORT $DBNAME
  RET=$?
done

DBINIT=$($MYSQL -s -e "SELECT COUNT(DISTINCT table_name) FROM information_schema.columns WHERE table_schema = '$DBNAME'" | head -1)
if [ ${DBINIT} -eq 0 ]; then
  echo "=> Initializing empty database"
  eval ${MYSQL} < /app/db/playsms.sql
else
  echo "=> Found existing database"
fi

CONFIG="/var/www/html/config.php"
if [ -w "$CONFIG" ]; then
  echo "=> Setting config defaults"
  sed -i "s/#DBHOST#/$DBHOST/g" $CONFIG
  sed -i "s/#DBPORT#/$DBPORT/g" $CONFIG
  sed -i "s/#DBNAME#/$DBNAME/g" $CONFIG
  sed -i "s/#DBUSER#/$DBUSER/g" $CONFIG
  sed -i "s/#DBPASS#/$DBPASS/g" $CONFIG
  sed -i "s|#PATHLOG#|/var/log/playsms|g" $CONFIG
else
  echo "=> Using existing read-only config"
  chown www-data.www-data $CONFIG
fi

echo "=> Starting playsmsd"
/usr/local/bin/playsmsd start

echo "=> Starting webserver"
apache2-foreground
