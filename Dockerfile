FROM huggla/alpine:20180424

ENV CONFIG_DIR="/etc/pgbouncer"

ENV REV_LINUX_USER="postgres" \
    REV_CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    REV_DATABASES="*=port=5432" \
    REV_DATABASE_USERS="" \
    REV_param_auth_file="$CONFIG_DIR/userlist.txt" \
    REV_param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    REV_param_unix_socket_dir="/run/pgbouncer" \
    REV_param_listen_addr="*"

COPY ./bin ${BIN_DIR}

RUN apk --no-cache add --virtual build-dependencies make libevent-dev openssl-dev gcc libc-dev \
 && buildDir="$(mktemp -d)" \
 && cd "$buildDir" \
 && wget -O pgbouncer-1.8.1.tar.gz http://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz \
 && tar xvfz pgbouncer-1.8.1.tar.gz \
 && cd pgbouncer-1.8.1 \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && mv pgbouncer "$BIN_DIR/pgbouncer" \
 && chmod u=rx,g=rx,o= "$BIN_DIR/pgbouncer" \
 && cd / \
 && rm -rf "$buildDir" \
 && apk del build-dependencies \
 && apk --no-cache add libssl1.0 libevent
 
USER sudoer
