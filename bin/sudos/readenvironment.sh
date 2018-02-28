#!/bin/sh
set -e +a +m +s +i -f

readonly SUDOS_DIR="$(/usr/bin/dirname $0)"
readonly USER_ENVIRONMENT_FILE="$SUDOS_DIR/user_environment"
if [ -f "$USER_ENVIRONMENT_FILE" ]
then
   /usr/bin/env > "$USER_ENVIRONMENT_FILE"
fi
unset password_$SUDO_USER
exec /usr/bin/env -i "$SUDOS_DIR/initpgbouncer.sh"
