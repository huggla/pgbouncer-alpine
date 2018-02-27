FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDO_DIR="$BIN_DIR/sudo"
ENV CONFIG_DIR="/etc/pgbouncer"
ENV ENVIRONMENT_FILE="$SUDO_DIR/environment" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    SUDOERS_FILE="/etc/sudoers.d/docker" \
    USER="pgbouncer" \
    PATH="$BIN_DIR"

RUN /usr/sbin/addgroup -S $USER \
 && /usr/sbin/adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
 && /usr/bin/env > "$ENVIRONMENT_FILE" \
    && /bin/chown root:$USER "$ENVIRONMENT_FILE" \
    && /bin/chmod u=rw,g=w,o= "$ENVIRONMENT_FILE" \
 && /sbin/apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
 && /usr/bin/wget -O /tmp/pgbouncer-1.8.1.tar.gz https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && cd /tmp \
 && /bin/tar xvfz /tmp/pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && /bin/mv pgbouncer "$BIN_DIR/" \
 && cd /tmp \
 && /bin/rm -rf /tmp/pgbouncer* \
 && /sbin/apk del build-dependencies \
    && /bin/chown root:$USER "$BIN_DIR/pgbouncer" \
    && /bin/chmod u=rx,g=rx,o= "$BIN_DIR/pgbouncer" \
 && /bin/mkdir -p "$CONFIG_DIR" \
 && /bin/touch "$CONFIG_FILE" \
    && /bin/chown root:$USER "$CONFIG_DIR" "$CONFIG_FILE" \
    && /bin/chmod u=rx,g=rx,o= "$CONFIG_DIR" \
    && /bin/chmod u=rw,g=r,o= "$CONFIG_FILE" \
 && /sbin/apk --no-cache add libssl1.0 libevent sudo \
    && /bin/chmod u=rx,go= "$SUDO_DIR/"* \
 && /bin/echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && /bin/echo "$USER ALL=(root) NOPASSWD: $SUDO_DIR/initpgbouncer.sh" >> "$SUDOERS_FILE" \
    && /bin/chmod u=rw,go= "$SUDOERS_FILE" \
    && /bin/chown root:$USER "$BIN_DIR/start.sh" \
    && /bin/chmod u=rx,g=rx,o= "$BIN_DIR/start.sh"

ENV DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_unix_socket_dir="/run/pgbouncer" \
    param_listen_addr="*"

USER ${USER}

CMD ["start.sh"]
