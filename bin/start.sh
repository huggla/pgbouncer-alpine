#!/bin/sh
set -e
IFS=","

if [ ! -e "$CONFIG_FILE" ]
then
   mkdir -p "$(dirname "$CONFIG_FILE")"
   echo "[databases]" >> "$CONFIG_FILE"
   for db in $DATABASES
   do
      echo "$db" >> "$CONFIG_FILE"
   done
   echo
   echo "[pgbouncer]" >> "$CONFIG_FILE"
   echo "listen_addr = \"$LISTEN_ADDR\"" >> "$CONFIG_FILE"
   echo "auth_file = \"$AUTH_FILE\""  >> "$CONFIG_FILE"
   if [ -n "$AUTH_HBA_FILE" ]
   then
      echo "auth_type = hba" >> "$CONFIG_FILE"
      echo "auth_hba_file = \"$AUTH_HBA_FILE\""  >> "$CONFIG_FILE"
   fi
   echo "unix_socket_dir = \"$UNIX_SOCKET_DIR\"" >> "$CONFIG_FILE"
   for conf in $ADDITIONAL_CONFIGURATION
   do
      echo "$conf" >> "$CONFIG_FILE"
   done
fi

if [ ! -e "$AUTH_FILE" ]
then
   mkdir -p "$(dirname "$AUTH_FILE")"
   for auth in $AUTH
   do
      echo "$auth" >> "$AUTH_FILE"
   done
fi

if [ ! -e "$AUTH_HBA_FILE" ] && [ -n "$AUTH_HBA" ]
then
   mkdir -p "$(dirname "$AUTH_HBA_FILE")"
   for hba in $AUTH_HBA
   do
      echo "$hba" >> "$AUTH_HBA_FILE"
   done
fi

if [ ! -e "$UNIX_SOCKET_DIR" ]
then
   mkdir -p "$UNIX_SOCKET_DIR"
fi

pgbouncer "$CONFIG_FILE"
