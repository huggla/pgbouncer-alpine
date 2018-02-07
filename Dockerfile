FROM alpine:3.7

COPY ./bin/start.sh ./bin/chown2root /usr/local/bin/

ENV CONFIG_DIR="/etc/pgbouncer" \
    UNIX_SOCKET_DIR="/var/run/pgbouncer"

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
 && apk --no-cache add libssl1.0 libevent sudo \
 && chmod +x /usr/local/bin/start.sh \
 && chmod u=rx,go= /usr/local/bin/chown2root \
 && mkdir -p "$CONFIG_DIR" "$UNIX_SOCKET_DIR" \
 && chown pgbouncer "$CONFIG_DIR" "$UNIX_SOCKET_DIR" \
 && echo "pgbouncer ALL=(root) NOPASSWD: /usr/local/bin/chown2root" > /etc/sudoers.d/pgbouncer

ENV CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    AUTH_FILE="$CONFIG_DIR/userlist.txt" \
    AUTH_HBA_FILE="$CONFIG_DIR/pg_hba.conf" \
    DATABASES="*=port=5432" \
    LISTEN_ADDR="*"

USER pgbouncer

CMD ["start.sh"]
