FROM alpine:3.7

COPY ./bin/start.sh /usr/local/bin/start.sh

ENV CONFIG_DIR /etc/pgbouncer

RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && cp pgbouncer /usr/local/bin \
 && adduser -D -S -u 100 pgbouncer \
 && cd /tmp \
 && rm -rf /tmp/pgbouncer* \
 && apk del build-dependencies \
 && apk --no-cache add libssl1.0 libevent \
 && chmod ugo+x /usr/local/bin/start.sh \
 && mkdir -p "$CONFIG_DIR" \
 && chown pgbouncer "$CONFIG_DIR"

ENV CONFIG_FILE "$CONFIG_DIR/pgbouncer.ini"
ENV AUTH_FILE "$CONFIG_DIR/userlist.txt"
ENV DATABASES "* = port=5432"
ENV LISTEN_ADDR *

USER pgbouncer

CMD ["/usr/local/bin/start.sh"]
