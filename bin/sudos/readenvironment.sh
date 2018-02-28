#!/bin/sh

set -e +a +m +s +i -f
USER=$SUDO_USER
echo $USER
if [ -f "$USER_ENVIRONMENT_FILE" ]
then
   /usr/bin/env > "$USER_ENVIRONMENT_FILE"
   unset password_$USER
   exec /usr/bin/env -i "$(/usr/bin/dirname $0)/initpgbouncer.sh"
else
   unset password_$USER
   exec /usr/bin/env -i sudo -u $USER pgbouncer "$CONFIG_FILE"
fi
