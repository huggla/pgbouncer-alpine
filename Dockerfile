FROM alpine:3.7

ENV BIN_DIR="/usr/local/bin"

COPY ./bin ${BIN_DIR}

ENV SUDOS_DIR="$BIN_DIR/sudos"
ENV CONFIG_DIR="/etc/pgbouncer"
ENV BUILDTIME_ENVIRONMENT="$SUDOS_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$SUDOS_DIR/runtime_environment" \
    CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    SUDOERS_DIR="/etc/sudoers.d" \
    USER="pgbouncer"

RUN addgroup -S $USER \
 && adduser -D -S -H -s /bin/false -u 100 -G $USER $USER \
    && chmod go= /bin /sbin /usr/bin /usr/sbin \
 && env > "$BUILDTIME_ENVIRONMENT" \
 && touch "$RUNTIME_ENVIRONMENT" \
    && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" \
    && chown root:$USER "$RUNTIME_ENVIRONMENT" \
    && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
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
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$SUDOS_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "DATABASES DATABASE_USERS param_* AUTH_HBA password_*"' > "$SUDOERS_DIR/docker2" \
 && echo "$USER ALL=(root) NOPASSWD: $SUDOS_DIR/readenvironment.sh" >> "$SUDOERS_DIR/docker2" \
    && chmod u=rw,go= "$SUDOERS_DIR/*" \
    && chmod u=rx,go= "$SUDOS_DIR/readenvironment.sh" "$SUDOS_DIR/initpgbouncer.sh"

USER ${USER}

ENV PATH="$BIN_DIR:$SUDOS_DIR" \
    DATABASES="*=port=5432" \
    DATABASE_USERS="" \
    param_auth_file="$CONFIG_DIR/userlist.txt" \
    param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    param_unix_socket_dir="/run/pgbouncer" \
    param_listen_addr="*"

CMD ["sudo","readenvironment.sh"]
