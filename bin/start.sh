#!/bin/sh
set -e
set +a
set +m
set +s
set +i

env > "$ENVIRONMENT_FILE"
env -i sudo "$SUDO_DIR/runpgbouncer.sh"
exec env -i pgbouncer "$CONFIG_FILE"
exit 0
