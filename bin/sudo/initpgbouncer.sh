#!/bin/sh
set -e
set +a
set +m
set +s
set +i

#readonly PATH=""
readonly SUDO_DIR="$(/usr/bin/dirname $0)"
readonly ENVIRONMENT_FILE="$SUDO_DIR/environment"
if [ -f "$ENVIRONMENT_FILE" ]
then
   IFS=$(echo -en "\n\b,")
   readonly environment="$(/bin/cat "$ENVIRONMENT_FILE" | /usr/bin/tr -dc '[:alnum:]_ %,-*.=/\n')"
   /bin/rm "$ENVIRONMENT_FILE"
   var(){
      IFS_bak=$IFS
      IFS=?
      if [ "$1" == "-" ]
      then
         tmp="$environment"
      else
         tmp="$(echo $environment | /usr/bin/awk -v section=$1 -F_ '$1==section{s= ""; for (i=2; i < NF; i++) s = s $i "_"; print s $NF}')"
      fi
      if [ -z "$2" ]
      then
         echo $tmp | /usr/bin/awk -F= '{print $1}'
      else
         echo $tmp | /usr/bin/awk -v param=$2 -F= '$1==param{print $2}'
      fi
      IFS=$IFS_bak
   }
   makedir(){
      /bin/mkdir -p "$1"
      set +e
      /bin/chown root "$1"
      /bin/chmod u=rwx,go=x "$1"
      set -e
   }
   makefile(){
      makedir "$(/usr/bin/dirname "$1")"
      set +e
      /bin/touch "$1"
      /bin/chown root "$1"
      /bin/chmod u=rw,go= "$1"
      set -e
   }
   trim(){
      echo "$1" | /usr/bin/awk '{$1=$1;print}'
   }
   tolower(){
      echo "$1" | /usr/bin/tr '[:upper:]' '[:lower:]'
   }
   readonly CONFIG_FILE="$(var - CONFIG_FILE)"
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
            echo $hba >> "$param_auth_hba_file"
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
            userpwfile="$SUDO_DIR/$user_lc"
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
         echo "\"$user\" \"$(cat "$userpwfile")\"" >> "$param_auth_file"
         set +e
         /bin/rm -f "$userpwfile"
         set -e
      done
   fi
   readonly param_unix_socket_dir="$(var param unix_socket_dir)"
   makedir "$param_unix_socket_dir"
fi
exit 0
