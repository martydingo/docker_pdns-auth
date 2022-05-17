export DB_PROTOCOL=`cat /etc/pdns/pdns.conf | grep "launch" | sed "s/launch=//"`
export DB_HOST=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-host" | sed "s/$DB_PROTOCOL-host=//"`
export DB_PORT=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-port" | sed "s/$DB_PROTOCOL-port=//"`
export DB_DBNAME=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-dbname" | sed "s/$DB_PROTOCOL-dbname=//"`
export DB_USER=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-user" | sed "s/$DB_PROTOCOL-user=//"`
export DB_PASSWORD=`cat /etc/pdns/pdns.conf | grep "$DB_PROTOCOL-password" | sed "s/$DB_PROTOCOL-password=//"`