FROM alpine:3.7

# Image-specific BEV_NAME variable.
# ---------------------------------------------------------------------
ENV BEV_NAME="pgbouncer"
# ---------------------------------------------------------------------

ENV BIN_DIR="/usr/local/bin" \
    SUDOERS_DIR="/etc/sudoers.d" \
    CONFIG_DIR="/etc/$BEV_NAME" \
    LANG="en_US.UTF-8"
ENV BUILDTIME_ENVIRONMENT="$BIN_DIR/buildtime_environment" \
    RUNTIME_ENVIRONMENT="$BIN_DIR/runtime_environment"

# Image-specific buildtime environment variables.
# ---------------------------------------------------------------------
ENV BEV_CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini"
# ---------------------------------------------------------------------

COPY ./bin ${BIN_DIR}

# Image-specific COPY commands.
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
    
RUN env | grep "^BEV_" > "$BUILDTIME_ENVIRONMENT" \
 && addgroup -S sudoer \
 && adduser -D -S -H -s /bin/false -u 100 -G sudoer sudoer \
 && (getent group $BEV_NAME || addgroup -S $BEV_NAME) \
 && (getent passwd $BEV_NAME || adduser -D -S -H -s /bin/false -u 101 -G $BEV_NAME $BEV_NAME) \
 && touch "$RUNTIME_ENVIRONMENT" \
 && apk add --no-cache sudo \
 && echo 'Defaults lecture="never"' > "$SUDOERS_DIR/docker1" \
 && echo "Defaults secure_path = \"$BIN_DIR\"" >> "$SUDOERS_DIR/docker1" \
 && echo 'Defaults env_keep = "REV_*"' > "$SUDOERS_DIR/docker2" \
 && echo "sudoer ALL=(root) NOPASSWD: $BIN_DIR/start" >> "$SUDOERS_DIR/docker2"

# Image-specific RUN commands.
# ---------------------------------------------------------------------
RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev  \
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
 && chown root:$BEV_NAME "$BIN_DIR/pgbouncer" \
 && chmod u=rx,g=rx,o= "$BIN_DIR/pgbouncer" \
 && apk --no-cache add libssl1.0 libevent
# ---------------------------------------------------------------------
    
RUN chmod go= /bin /sbin /usr/bin /usr/sbin \
 && chown root:$BEV_NAME "$BIN_DIR/"* \
 && chmod u=rx,g=rx,o= "$BIN_DIR/"* \
 && ln /usr/bin/sudo "$BIN_DIR/sudo" \
 && chown root:sudoer "$BIN_DIR/sudo" "$BUILDTIME_ENVIRONMENT" "$RUNTIME_ENVIRONMENT" \
 && chown root:root "$BIN_DIR/start"* \
 && chmod u+s "$BIN_DIR/sudo" \
 && chmod u=rw,g=w,o= "$RUNTIME_ENVIRONMENT" \
 && chmod u=rw,go= "$BUILDTIME_ENVIRONMENT" "$SUDOERS_DIR/docker"*
 
USER sudoer

# Image-specific runtime environment variables.
# ---------------------------------------------------------------------
ENV REV_DATABASES="*=port=5432" \
    REV_DATABASE_USERS="" \
    REV_param_auth_file="$CONFIG_DIR/userlist.txt" \
    REV_param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    REV_param_unix_socket_dir="/run/pgbouncer" \
    REV_param_listen_addr="*"
# ---------------------------------------------------------------------

ENV PATH="$BIN_DIR"

CMD ["sudo","start"]
