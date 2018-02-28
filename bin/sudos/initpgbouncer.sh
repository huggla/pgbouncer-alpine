#!/bin/sh
set -e +a +m +s +i -f

readonly PATH=""
readonly SUDOS_DIR="$(/usr/bin/dirname $0)"
readonly SU_ENVIRONMENT_FILE="$SUDOS_DIR/su_environment"
readonly USER_ENVIRONMENT_FILE="$SUDOS_DIR/user_environment"
if [ -f "$SU_ENVIRONMENT_FILE" ]
then
   IFS=$(echo -en "\n\b,")
   readonly environment="$(/bin/cat "$SU_ENVIRONMENT_FILE" "$USER_ENVIRONMENT_FILE" | /usr/bin/tr -dc '[:alnum:]_ %,\052\055.=/\012')"
   /bin/rm "$SU_ENVIRONMENT_FILE" "$USER_ENVIRONMENT_FILE"
   var(){
      IFS_bak=$IFS
      IFS=?
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | /usr/bin/awk -v section=$1 -F_ '$1==section{s=""; for (i=2; i < NF; i++) s = s $i "_"; print s $NF}')"
      fi
      if [ -z "$2" ]
      then
         echo $tmp | /usr/bin/awk -F= '{print $1}'
      else
         echo $tmp | /usr/bin/awk -v param=$2 -F= '$1==param{s=""; for (i=2; i < NF; i++) s = s $i "="; print s $NF; exit;}'
      fi
      IFS=$IFS_bak
   }
   makedir(){
      /bin/mkdir -p "$1"
      set +e
      /bin/chown root:$USER "$1"
      /bin/chmod u=rwx,g=x,o= "$1"
      set -e
   }
   makefile(){
      makedir "$(/usr/bin/dirname "$1")"
      set +e
      /bin/touch "$1"
      /bin/chown root:$USER "$1"
      /bin/chmod u=rw,g=r,o= "$1"
      set -e
   }
   trim(){
      echo "$1" | /usr/bin/awk '{$1=$1;print}'
   }
   tolower(){
      echo "$1" | /usr/bin/tr '[:upper:]' '[:lower:]'
   }
 #  /bin/rm -rf "$SUDOS_DIR"
   readonly SUDOERS_FILE="$(var - SUDOERS_FILE)"
   /bin/rm "$SUDOERS_FILE"
   readonly BIN_DIR="$(var - BIN_DIR)"
   /bin/rm "$BIN_DIR/sudo"
   readonly CONFIG_FILE="$(var - CONFIG_FILE)"
   echo "#!$BIN_DIR/sh" > "$BIN_DIR/start.sh"
   echo "set -e +a +m +s +i -f" >> "$BIN_DIR/start.sh"
   echo "exec env -i pgbouncer \"$CONFIG_FILE\"" >> "$BIN_DIR/start.sh"
   readonly USER="$(var - USER)"
   if [ ! -s "$CONFIG_FILE" ]
   then
      echo "[databases]" > "$CONFIG_FILE"
      readonly DATABASES="$(var - DATABASES)"
      for db in $DATABASES
      do
         echo "$db" >> "$CONFIG_FILE"
      done
      echo >> "$CONFIG_FILE"
      echo "[pgbouncer]" >> "$CONFIG_FILE"
      readonly pgbouncer_parameters="$(var param)"
      for param in $pgbouncer_parameters
      do
         param_value="$(var param $param)"
         if [ -n "$param_value" ]
         then
            echo -n "$param" >> "$CONFIG_FILE"
            echo "=$param_value" >> "$CONFIG_FILE"
         fi
      done
   fi
   readonly param_auth_type="$(var param auth_type)"
   if [ "$param_auth_type" == "hba" ]
   then
      readonly param_auth_hba_file="$(var param auth_hba_file)"
      makefile "$param_auth_hba_file"
      if [ ! -s "$param_auth_hba_file" ]
      then
         readonly AUTH_HBA="$(var - AUTH_HBA)"
         for hba in $AUTH_HBA
         do
            trim $hba >> "$param_auth_hba_file"
         done
      fi
   fi
   readonly param_auth_file="$(var param auth_file)"
   makefile "$param_auth_file"
   if [ ! -s "$param_auth_file" ]
   then
      readonly DATABASE_USERS="$(echo "$(var - DATABASE_USERS)" | /usr/bin/awk '{$1=$1;print}')"
      for user in $DATABASE_USERS
      do
         user="$(trim "$user")"
         user_lc="$(tolower "$user")"
         userpwfile="$(var - password_file_$user_lc)"
         if [ -z "$userpwfile" ]
         then
            userpwfile="$SUDOS_DIR/$user_lc"
         fi
         makefile "$userpwfile"
         if [ ! -s "$userpwfile" ]
         then
            user_pw="$(var - password_$user_lc)"
            if [ -n "$user_pw" ]
            then
               echo -n "$user_pw" > $userpwfile
               unset user_pw
            else
               echo "No password given for $user."
               exit 1
            fi
         fi
         echo "\"$user\" \"$(/bin/cat "$userpwfile")\"" >> "$param_auth_file"
         set +e
         /bin/rm -f "$userpwfile"
         set -e
      done
   fi
   readonly param_unix_socket_dir="$(var param unix_socket_dir)"
   makedir "$param_unix_socket_dir"
fi
exit 0
