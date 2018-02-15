FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV CONFIG_DIR="/etc/pgbouncer" \
    UNIX_SOCKET_DIR="/var/run/pgbouncer" \
    SUDO_DIR="$BIN_DIR/sudo" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini"

RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && chmod 500 "$SUDO_DIR/*" "$BIN_DIR/*" \
 && wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && cp pgbouncer /usr/local/bin \
 && adduser -D -S -H -s /bin/false -u 100 pgbouncer \
 && cd /tmp \
 && rm -rf /tmp/pgbouncer* \
 && apk del build-dependencies \
 && apk --no-cache add libssl1.0 libevent sudo \
 && mkdir -p "$CONFIG_DIR" "$UNIX_SOCKET_DIR" \
 && chown pgbouncer "$CONFIG_DIR" "$UNIX_SOCKET_DIR" "$BIN_DIR/*" \
 && echo "pgbouncer ALL=(root) NOPASSWD: '$SUDO_DIR/*'" > /etc/sudoers.d/samba

ENV DATABASES="*=port=5432" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_listen_addr="*"

USER pgbouncer

CMD ["start.sh"]
