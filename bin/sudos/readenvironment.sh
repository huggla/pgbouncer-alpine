#!/bin/sh

set -e +a +m +s +i -f

unset PATH
/usr/bin/env > "$USER_ENVIRONMENT_FILE"
unset password_$USER
exec /usr/bin/env -i "$SUDOS_DIR/initpgbouncer.sh"
