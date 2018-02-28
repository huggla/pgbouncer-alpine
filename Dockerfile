FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDOS_DIR="$BIN_DIR/sudos"
ENV CONFIG_DIR="/etc/pgbouncer"
ENV SU_ENVIRONMENT_FILE="$SUDOS_DIR/su_environment" \
    USER_ENVIRONMENT_FILE="$SUDOS_DIR/user_environment" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    SUDOERS_FILE="/etc/sudoers.d/docker" \
    USER="pgbouncer"

RUN ["/bin/ln","/bin/busybox","/bin/busybox2"]

RUN addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
# && mv /bin/busybox2 "$BIN_DIR/busybox"
    && chmod go= /bin /sbin /usr/bin /usr/sbin \
 #   && chown root:$USER /bin/busybox \
 #   && chmod u=rx,g=rx,o= /bin/busybox \
 && env > "$SU_ENVIRONMENT_FILE" \
 && touch "$USER_ENVIRONMENT_FILE" \
    && chmod u=rw,go= "$SU_ENVIRONMENT_FILE" \
    && chown root:$USER "$USER_ENVIRONMENT_FILE" \
    && chmod u=rw,g=w,o= "$USER_ENVIRONMENT_FILE" \
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
    && chmod 4750 /usr/bin/sudo \
    && chown root:$USER /usr/bin/sudo \
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && echo 'Defaults lecture="never"' > "$SUDOERS_FILE" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDOS_DIR/initpgbouncer.sh" >> "$SUDOERS_FILE" \
    && chmod u=rw,go= "$SUDOERS_FILE" \
# && echo "#!$BIN_DIR/sh" > "$BIN_DIR/start.sh" \
# && echo "set -e +a +m +s +i -f" >> "$BIN_DIR/start.sh" \
# && echo "env > \"$USER_ENVIRONMENT_FILE\"" >> "$BIN_DIR/start.sh" \
# && echo "env -i sudo \"$SUDOS_DIR/initpgbouncer.sh\"" >> "$BIN_DIR/start.sh" \
# && echo "exec env -i pgbouncer \"$CONFIG_FILE\"" >> "$BIN_DIR/start.sh" \
 && echo "exec \"$BIN_DIR/sudo\" \"$SUDOS_DIR/readenvironment.sh\"" > "$BIN_DIR/start.sh" \
    && chmod u=rx,go= "$SUDOS_DIR/readenvironment.sh" "$SUDOS_DIR/initpgbouncer.sh" \
    && chown root:$USER "$BIN_DIR/start.sh" \
    && chmod u=rx,g=rx,o= "$BIN_DIR/start.sh"

USER ${USER}

ENV PATH="$BIN_DIR:$SUDOS_DIR" \
    DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_unix_socket_dir="/run/pgbouncer" \
    param_listen_addr="*"

CMD ["sudo","readenvironment.sh"]
