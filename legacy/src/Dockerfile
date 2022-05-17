FROM alpine:3.14

RUN apk add --no-cache \
      mariadb-client \
      mysql-client \
      pdns \
      pdns-backend-mysql \
      pdns-doc

COPY pdns.conf /etc/pdns/pdns.conf

RUN mkdir -p /etc/pdns/pdns.conf.d \
  && chown -R pdns: /etc/pdns/pdns.conf.d

COPY docker-entrypoint.sh /

EXPOSE 53
EXPOSE 53/udp
EXPOSE 8081

RUN ["chmod", "+x", "/docker-entrypoint.sh"]

ENTRYPOINT [ "sh", "docker-entrypoint.sh" ]

CMD [ "/usr/sbin/pdns_server" ]
