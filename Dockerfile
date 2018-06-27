FROM huggla/alpine as tmp

USER root

# Build-only variables
ENV PGBOUNCER_VERSION="1.8.1" \
    CONFIG_DIR="/etc/pgbouncer"

RUN apk --no-cache add libssl1.0 libevent \
 && apk --no-cache add --virtual .build-dependencies make libevent-dev openssl-dev gcc libc-dev \
 && downloadDir="$(mktemp -d)" \
 && wget -O "$downloadDir/pgbouncer.tar.gz" https://pgbouncer.github.io/downloads/files/$PGBOUNCER_VERSION/pgbouncer-$PGBOUNCER_VERSION.tar.gz \
 && buildDir="$(mktemp -d)" \
 && tar xvfz "$downloadDir/pgbouncer.tar.gz" -C "$buildDir" --strip-components=1 \
 && rm -rf "$downloadDir" \
 && cd "$buildDir" \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && mv ./pgbouncer /usr/local/bin/pgbouncer \
 && cd / \
 && rm -rf "$buildDir" \
 && apk del .build-dependencies

FROM huggla/alpine

COPY ./start /start
COPY --from=tmp /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

RUN apk --no-cache add libssl1.0 libevent

ENV VAR_LINUX_USER="postgres" \
    VAR_CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    VAR_DATABASES="*=port=5432" \
    VAR_param_auth_file="$CONFIG_DIR/userlist.txt" \
    VAR_param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    VAR_param_unix_socket_dir="/run/pgbouncer" \
    VAR_param_listen_addr="*" \
    VAR_FINAL_COMMAND="/usr/local/bin/pgbouncer \$VAR_CONFIG_FILE"
 
USER starter
