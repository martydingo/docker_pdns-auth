#!/bin/sh

set -euo pipefail

# Configure Database Environment Variables
export DB_PROTOCOL=`cat /etc/pdns/pdns.conf | grep "launch" | sed "s/launch=//"`
export DB_HOST=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-host" | sed "s/$DB_PROTOCOL-host=//"`
export DB_PORT=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-port" | sed "s/$DB_PROTOCOL-port=//"`
export DB_DBNAME=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-dbname" | sed "s/$DB_PROTOCOL-dbname=//"`
export DB_USER=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-user" | sed "s/$DB_PROTOCOL-user=//"`
export DB_PASSWORD=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-password" | sed "s/$DB_PROTOCOL-password=//"`


if [ "${DB_PROTOCOL}"] == "gmysql" ]; 
then

    DB_COMMAND="mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD}"

    # Wait for MySQL to respond
    while ! mysqladmin ping -h"$DB_HOST" --silent; do
        >&2 echo 'MySQL is unavailable - sleeping'
        sleep 3
    done

    # Initialize DB if needed
    $DB_COMMAND -e "CREATE DATABASE IF NOT EXISTS ${DB_DATABASE}"

    DB_CHECK_IF_HAS_TABLE="SELECT COUNT(DISTINCT table_name) FROM information_schema.columns WHERE table_schema = '${DB_DATABASE}';"
    DB_NUM_TABLE=$($DB_COMMAND --batch --skip-column-names -e "$DB_CHECK_IF_HAS_TABLE")

    if [ "$DB_NUM_TABLE" -eq 0 ]; then
        $DB_COMMAND -D "$DB_DATABASE" < /usr/share/doc/pdns/schema.mysql.sql
    fi
    
else
    echo "Sorry, only the gmysql backend is supported at this stage, although support for more database backends is coming!"
    echo "Please use the gmysql backend"
    sleep 86400
fi

exec "$@"
