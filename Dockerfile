FROM huggla/alpine-slim as stage1

ARG APKS="libevent"
ARG PGBOUNCER_VERSION="1.8.1"
ARG CONFIG_DIR="/etc/pgbouncer"

COPY ./rootfs /rootfs

RUN apk --no-cache --root /rootfs add $APKS \
 && apk --no-cache add --virtual .build-dependencies make libevent-dev libressl-dev gcc libc-dev \
 && downloadDir="$(mktemp -d)" \
 && wget -O "$downloadDir/pgbouncer.tar.gz" https://pgbouncer.github.io/downloads/files/$PGBOUNCER_VERSION/pgbouncer-$PGBOUNCER_VERSION.tar.gz \
 && buildDir="$(mktemp -d)" \
 && tar xvfz "$downloadDir/pgbouncer.tar.gz" -C "$buildDir" --strip-components=1 \
 && rm -rf "$downloadDir" \
 && cd "$buildDir" \
 && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
 && make \
 && cp -a $buildDir/pgbouncer /rootfs/usr/local/bin/ \
 && cd / \
 && rm -rf "$buildDir" \
 && apk --no-cache del .build-dependencies

FROM huggla/base

ENV VAR_LINUX_USER="postgres" \
    VAR_CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    VAR_DATABASES="*=port=5432" \
    VAR_param_auth_file="$CONFIG_DIR/userlist.txt" \
    VAR_param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    VAR_param_unix_socket_dir="/run/pgbouncer" \
    VAR_param_listen_addr="*" \
    VAR_FINAL_COMMAND="/usr/local/bin/pgbouncer \$VAR_CONFIG_FILE"
 
ONBUILD USER root
