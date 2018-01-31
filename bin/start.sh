#!/bin/bash

if [ ! -e "$CONFIG_FILE" ]
then
   echo "[databases]" > "$CONFIG_FILE"
   IFS=, read -ra db_rows <<< "$DATABASES"
   for db in "${db_rows[@]}"
   do
      echo "$db" >> "$CONFIG_FILE"
   done
   echo
   echo "[pgbouncer]" >> "$CONFIG_FILE"
   echo "listen_addr = \"$LISTEN_ADDR\"" >> "$CONFIG_FILE"
   echo "auth_file = \"$AUTH_FILE\""  >> "$CONFIG_FILE"
   if [ -n $AUTH_HBA_FILE ]
   then
      echo "auth_type = hba" >> "$CONFIG_FILE"
      echo "auth_hba_file = \"$AUTH_HBA_FILE\""  >> "$CONFIG_FILE"
   fi
   IFS=, read -ra configs <<< "$ADDITIONAL_CONFIGURATION"
   for conf in "${configs[@]}"
   do
      echo "$conf" >> "$CONFIG_FILE"
   done
fi

if [ ! -e "$AUTH_FILE" ]
then
   IFS=, read -ra auth_rows <<< "$AUTH"
   for auth in "${auth_rows[@]}"
   do
      echo "$auth" >> "$AUTH_FILE"
   done
fi

if [ ! -e "$AUTH_HBA_FILE" ] && [ -n $AUTH_HBA ]
then
   IFS=, read -ra hba_rows <<< "$AUTH_HBA"
   for hba in "${hba_rows[@]}"
   do
      echo "$hba" >> "$AUTH_HBA_FILE"
   done
fi

pgbouncer "$CONFIG_FILE"
