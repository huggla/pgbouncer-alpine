#!/bin/sh
set -e
set +a
set +m
set +s
set +i
set -f

readonly PATH=""
if [ -f "$SUDOERS_FILE" ] && [ -f "$ENVIRONMENT_FILE" ]
then
   env > "$ENVIRONMENT_FILE"
   env -i sudo "$SUDO_DIR/initpgbouncer.sh"
fi
exec env -i pgbouncer "$CONFIG_FILE"
exit 0
