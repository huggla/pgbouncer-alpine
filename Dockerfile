FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDO_DIR="$BIN_DIR/sudo"
ENV CONFIG_DIR="/etc/pgbouncer"
ENV ENVIRONMENT_FILE="$SUDO_DIR/environment" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    SUDOERS_FILE="/etc/sudoers.d/pgbouncer" \
    USER="pgbouncer"

RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && mkdir -p "$CONFIG_DIR" \
 && wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && cp pgbouncer "$BIN_DIR/" \
 && cd /tmp \
 && rm -rf /tmp/pgbouncer* \
 && apk del build-dependencies \
 && apk --no-cache add libssl1.0 libevent sudo \
 && chmod u=rx,g=rx,o= "$BIN_DIR/start.sh" "$BIN_DIR/pgbouncer" "$CONFIG_DIR" \
 && chmod u=rx,go= "$SUDO_DIR/"* \
 && touch "$ENVIRONMENT_FILE" "$CONFIG_FILE" \
 && chmod u=rw,g=w,o= "$ENVIRONMENT_FILE" \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && chown root:$USER "$CONFIG_DIR" "$BIN_DIR/start.sh" "$BIN_DIR/pgbouncer" "$ENVIRONMENT_FILE" \
 && echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDO_DIR/initpgbouncer.sh" >> "$SUDOERS_FILE" \
 && chmod u=rw,go= "$SUDOERS_FILE"

ENV DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_unix_socket_dir="/run/pgbouncer" \
    param_listen_addr="*"

USER ${USER}

CMD ["start.sh"]
