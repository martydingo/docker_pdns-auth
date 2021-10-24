#!/bin/sh

set -euo pipefail

# Configure Database Variables
sed -i s/PLACEHOLDER_MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/g /etc/pdns/pdns.conf
sed -i s/PLACEHOLDER_MYSQL_HOST/$MYSQL_HOST/g /etc/pdns/pdns.conf
sed -i s/PLACEHOLDER_MYSQL_PORT/$MYSQL_PORT/g /etc/pdns/pdns.conf
sed -i s/PLACEHOLDER_MYSQL_DATABASE/$MYSQL_DATABASE/g /etc/pdns/pdns.conf
sed -i s/PLACEHOLDER_MYSQL_USER/$MYSQL_USER/g /etc/pdns/pdns.conf
sed -i s/PLACEHOLDER_MYSQL_PASSWORD/$MYSQL_PASSWORD/g /etc/pdns/pdns.conf

EXTRA=""

# Password Auth
if [ "${MYSQL_PASSWORD}" != "" ]; then
    EXTRA="${EXTRA} -p${MYSQL_PASSWORD}"
fi

MYSQL_COMMAND="mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER}${EXTRA}"

# Wait for MySQL to respond
while ! mysqladmin ping -h"$MYSQL_HOST" --silent; do
    >&2 echo 'MySQL is unavailable - sleeping'
    sleep 3
done

# Initialize DB if needed
$MYSQL_COMMAND -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"

MYSQL_CHECK_IF_HAS_TABLE="SELECT COUNT(DISTINCT table_name) FROM information_schema.columns WHERE table_schema = '${MYSQL_DATABASE}';"
MYSQL_NUM_TABLE=$($MYSQL_COMMAND --batch --skip-column-names -e "$MYSQL_CHECK_IF_HAS_TABLE")

if [ "$MYSQL_NUM_TABLE" -eq 0 ]; then
    $MYSQL_COMMAND -D "$MYSQL_DATABASE" < /usr/share/doc/pdns/schema.mysql.sql
fi

exec "$@"
