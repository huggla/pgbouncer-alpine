#!/bin/sh
set -e
set +a
set +m
set +s
set +i
set -f

if [ -f "$SUDOERS_FILE" ] && [ -f "$ENVIRONMENT_FILE" ]
then
   env > "$ENVIRONMENT_FILE"
   env -i sudo "$SUDOS_DIR/initpgbouncer.sh"
fi
exec env -i pgbouncer "$CONFIG_FILE"
exit 0
