#!/bin/sh
set -e
set +a
set +m
set +s
set +i

if [ -d "$SUDO_DIR" ]
then
   IFS="${IFS};"
   sudo="/usr/bin/sudo"
   if [ ! -s "$CONFIG_FILE" ]
   then
      echo "[databases]" > "$CONFIG_FILE"
      for db in $DATABASES
      do
         echo "$db" >> "$CONFIG_FILE"
      done
      echo >> "$CONFIG_FILE"
      echo "[pgbouncer]" >> "$CONFIG_FILE"
      pgbouncer_parameters=`env | /bin/grep "param" | /bin/sed "s/^param_//g" | /bin/grep -oE '^[^=]+'`
      for param in $pgbouncer_parameters
      do
         param_var="param_${param}"
         eval "param_value=\$$param_var"
         if [ -n "$param_value" ]
         then
            echo -n "$param" >> "$CONFIG_FILE"
            echo "=$param_value" >> "$CONFIG_FILE"
         fi
      done
   fi
   if [ "$param_auth_type" == "hba" ]
   then
      if [ ! -e "$param_auth_hba_file" ]
      then
         hba_file_dir="$(dirname "$param_auth_hba_file")"
         if [ ! -e "$hba_file_dir" ]
         then
            /bin/mkdir -p "$hba_file_dir"
         fi
         >"$param_auth_hba_file"
         for hba in $AUTH_HBA
         do
            echo $hba >> "$param_auth_hba_file"
         done
      fi
      env -i $sudo "$SUDO_DIR/chown2root" "$param_auth_hba_file"
   fi
   if [ ! -e "$param_auth_file" ]
   then
      auth_file_dir="$(dirname "$param_auth_file")"
      if [ ! -e "$auth_file_dir" ]
      then
         mkdir -p "$(dirname "$param_auth_file")"
      fi
      >"$param_auth_file"
      for user in $DATABASE_USERS
      do
         user_lc=$(echo $user | xargs | tr '[:upper:]' '[:lower:]')
         envvar="password_file_$user_lc"
         eval "userpwfile=\$$envvar"
         if [ -z "$userpwfile" ]
         then
            envvar="password_$user_lc"
            eval "user_pw=\$$envvar"
            if [ -n "$user_pw" ]
            then
               userpwfile=$CONFIG_DIR/$user"_pw"
               echo $user_pw > $userpwfile
               unset user_pw
               unset $envvar
            else
               echo "No password given for $user."
               exit 1
            fi
         fi
         env -i $sudo "$SUDO_DIR/chown2root" "$userpwfile"
         env -i $sudo "$SUDO_DIR/adduser2pgbouncerauth" "$user" "$userpwfile"
      done
   fi
         
         
            envvar="auth_hba_$user_lc"
            eval "user_hba=\$$envvar"
            echo $user_hba >> "$param_auth_hba_file"
         done
      
   for auth in $AUTH
   do
      echo "$auth" >> "$AUTH_FILE"
   done
fi

if [ ! -e "$UNIX_SOCKET_DIR" ]
then
   mkdir -p "$UNIX_SOCKET_DIR"
fi

sudo chown2root -R "$(dirname "$CONFIG_FILE")"
sudo chown2root -R "$(dirname "$AUTH_HBA_FILE")"
sudo chown2root -R "$(dirname "$AUTH_FILE")"
pgbouncer "$CONFIG_FILE"
exit 0
