ARG TAG="20181108-edge"
ARG RUNDEPS="pgbouncer"
ARG EXECUTABLES="/usr/bin/pgbouncer"

#---------------Don't edit----------------
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${BASEIMAGE:-huggla/base:$TAG} as base
FROM huggla/build:$TAG as build
FROM ${BASEIMAGE:-huggla/base:$TAG} as image
COPY --from=build /imagefs /
#-----------------------------------------

ARG CONFIG_DIR="/etc/pgbouncer"

ENV VAR_LINUX_USER="postgres" \
    VAR_CONFIG_FILE="$CONFIG_DIR/pgbouncer.ini" \
    VAR_DATABASES="*=port=5432" \
    VAR_param_auth_file="$CONFIG_DIR/userlist.txt" \
    VAR_param_auth_hba_file="$CONFIG_DIR/pg_hba.conf" \
    VAR_param_unix_socket_dir="/run/pgbouncer" \
    VAR_param_listen_addr="*" \
    VAR_param_logfile="/var/log/pgbouncer/pgbouncer.log" \
    VAR_FINAL_COMMAND="/usr/local/bin/pgbouncer \$VAR_CONFIG_FILE"

#---------------Don't edit----------------
USER starter
ONBUILD USER root
#-----------------------------------------
