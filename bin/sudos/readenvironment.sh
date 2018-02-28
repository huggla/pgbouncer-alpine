#!/bin/sh

set -e +a +m +s +i -f

if [ -f "$USER_ENVIRONMENT_FILE" ]
then
   /usr/bin/env > "$USER_ENVIRONMENT_FILE"
fi
unset password_$SUDO_USER
exec /usr/bin/env -i "$(/usr/bin/dirname $0)/initpgbouncer.sh"
