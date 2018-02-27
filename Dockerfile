FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDO_DIR="$BIN_DIR/sudo"
ENV CONFIG_DIR="/etc/pgbouncer"
ENV ENVIRONMENT_FILE="$SUDO_DIR/environment" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    SUDOERS_FILE="/etc/sudoers.d/docker" \
    USER="pgbouncer"

RUN chmod go= /bin /sbin /usr/bin /usr/sbin \
 && ln /usr/bin/env /usr/local/bin/env \
 && ln /bin/sh /usr/local/bin/sh \
 && addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && env > "$ENVIRONMENT_FILE" \
    && chown root:$USER "$ENVIRONMENT_FILE" \
    && chmod u=rw,g=w,o= "$ENVIRONMENT_FILE" \
 && apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && mv pgbouncer "$BIN_DIR/" \
 && cd /tmp \
 && rm -rf /tmp/pgbouncer* \
 && apk del build-dependencies \
    && chown root:$USER "$BIN_DIR/pgbouncer" \
    && chmod u=rx,g=rx,o= "$BIN_DIR/pgbouncer" \
 && mkdir -p "$CONFIG_DIR" \
 && touch "$CONFIG_FILE" \
    && chown root:$USER "$CONFIG_DIR" "$CONFIG_FILE" \
    && chmod u=rx,g=rx,o= "$CONFIG_DIR" \
    && chmod u=rw,g=r,o= "$CONFIG_FILE" \
 && apk --no-cache add libssl1.0 libevent sudo \
 && ln /usr/bin/sudo /usr/local/bin/sudo \
    && chmod u=rx,go= "$SUDO_DIR/"* \
 && echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDO_DIR/initpgbouncer.sh" >> "$SUDOERS_FILE" \
    && chmod u=rw,go= "$SUDOERS_FILE" \
    && chown root:$USER "$BIN_DIR/start.sh" \
    && chmod u=rx,g=rx,o= "$BIN_DIR/start.sh"

USER ${USER}

ENV PATH="$BIN_DIR" \
    DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_unix_socket_dir="/run/pgbouncer" \
    param_listen_addr="*"

CMD ["start.sh"]
