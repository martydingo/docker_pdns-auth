# Docker - PDNS Authoritative 
## Description
This is an image that pulls an Alpine Linux container, and installs PowerDNS Authoritative. This image avoids the need to have a prebuilt pdns.conf as to provide out-of-the-box functionaility, while providing the same level of customisation that including your own recursor.coinf brings.

The following configuration is baked into this image:

```conf
launch=gmysql
gmysql-host=PLACEHOLDER_MYSQL_HOST
gmysql-port=PLACEHOLDER_MYSQL_PORT
gmysql-dbname=PLACEHOLDER_MYSQL_DATABASE
gmysql-user=PLACEHOLDER_MYSQL_USER
gmysql-password=PLACEHOLDER_MYSQL_PASSWORD
gmysql-dnssec=yes
webserver=yes
webserver-address=0.0.0.0
webserver-allow-from=0.0.0.0/0
include-dir=/etc/pdns/pdns.conf.d/
```

On starting the container, a sed script will substitute the above placeholder values for variables configured within the `.env` file. 

This configuration can be overwritten/appended to by mounting a configuration directory holding `*.conf` files, to `/etc/pdns/pdns.conf.d/`

The webserver is enabled by default as so metrics can be scraped with no further configuration. However, the API will need a password configuring, and appended to a conf file inside the aforementioned configuration directory mount. This is accessible by default on `0.0.0.0:8081`

Alternatively, the `pdns.conf` inside the `src` directory can be modified, and a new image can be built by renaming `docker-compose.yml.build` to `docker-compose.yml`, and then running `docker-compose build`.

## Usage
To run this image, update the database environment variables inside the included .env file

```shell
MYSQL_ROOT_PASSWORD=WhatASecureRootPassword
MYSQL_HOST=db
MYSQL_PORT=3306
MYSQL_DATABASE=pdns
MYSQL_USER=pdns
MYSQL_PASSWORD=WhatASecureUserspacePassword
```

Modify the `config` and `db` volume mounts inside the included docker-compose.yml, create the `config` and `db` directories where you have target these mounts to, and then run `docker-compose up` to start pdns.

```yaml
services:
  db:
    container_name: pdns_db
    image: mariadb
    restart: unless-stopped
    env_file: .env
    volumes:
      - <PATH_OF_DB_MOUNT>:/var/lib/mysql
    networks: 
      db:
  
  auth:
    container_name: pdns_auth
    image: martydingo/pdns-auth
    env_file: .env
    ports:
      - 53:53
      - 53:53/udp
      - 8081:8081
    networks:
      db:
    volumes:
      - <PATH_OF_CONFIG_MOUNT>:/etc/pdns/recursor.conf.d/

networks:
  db:
```

This image can also be built and run from scratch by following the same process aforementioned, but using the `docker-compose.yml` file inside the `src` directory found in this repository rather then at the `docker-compose.yml` found at the root of this repository

```yaml
services:
  db:
    container_name: pdns_db
    image: mariadb
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./db:/var/lib/mysql
    networks: 
      db:
  
  auth:
    container_name: pdns_auth
    env_file: .env
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - 53:53
      - 53:53/udp
      - 8081:8081
    networks:
      db:
    volumes:
      - ./config:/etc/pdns/recursor.conf.d/

networks:
  db:
```