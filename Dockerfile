FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV CONFIG_DIR="/etc/pgbouncer" \
    SUDO_DIR="$BIN_DIR/sudo" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    USER="pgbouncer" \
    param_unix_socket_dir="/var/run/pgbouncer"

RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && mkdir -p "$CONFIG_DIR" "$param_unix_socket_dir" \
 && wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && cp pgbouncer /usr/local/bin \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && chmod u=rx,go= "$SUDO_DIR/"* \
 && chmod u=rwx,g=wx,o= "$CONFIG_DIR" "$param_unix_socket_dir" \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && cd /tmp \
 && rm -rf /tmp/pgbouncer* \
 && apk del build-dependencies \
 && apk --no-cache add libssl1.0 libevent sudo \
 && chown root:$USER "$CONFIG_DIR" "$param_unix_socket_dir" "$BIN_DIR/"* \
 && chown $USER "$CONFIG_FILE" \
 && echo "$USER HOST=(root) NOPASSWD: $(find "$SUDO_DIR" -type f | paste -d, -s )" > /etc/sudoers.d/pgbouncer \
 && chmod u=rw,go= "$SUDOERS_FILE" "$CONFIG_FILE"

ENV DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_listen_addr="*"

USER ${USER}

CMD ["start.sh"]
