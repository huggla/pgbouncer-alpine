#!/bin/sh

#set -e +a +m +s +i -f
/usr/bin/env > /usr/local/bin/apa
unset PATH
if [ -f "$USER_ENVIRONMENT_FILE" ]
then
   /usr/bin/env > "$USER_ENVIRONMENT_FILE"
fi
unset password_$USER
exec /usr/bin/env -i "$SUDOS_DIR/initpgbouncer.sh"
