#!/usr/local/bin/sh
set -e +a +m +s +i -f

env > "$USER_ENVIRONMENT_FILE"
env -i sudo "$SUDOS_DIR/initpgbouncer.sh"
exec env -i pgbouncer "$CONFIG_FILE"
exit 0
