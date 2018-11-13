**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# pgbouncer-alpine
A secure and minimal docker image with Pgbouncer. Listens by default on port 6432.

## Environment variables
### pre-set runtime variables
* VAR_LINUX_USER (postgres)
* VAR_CONFIG_FILE (/etc/pgbouncer/pgbouncer.ini)
* VAR_ARGON2_PARAMS (-r): Only used if VAR_ENCRYPT_PW is set to "yes".
* VAR_SALT_FILE (/proc/sys/kernel/hostname): Only used if VAR_ENCRYPT_PW is set to "yes".
* VAR_FINAL_COMMAND (/usr/local/bin/pgbouncer \$VAR_CONFIG_FILE)
* VAR_DATABASES (*=port=5432): Comma separated list of backend databases. Default set to only read from Unix socket.
* VAR_param_auth_file (/etc/pgbouncer/userlist.txt): Pgbouncer authentication file.
* VAR_param_auth_hba_file (/etc/pgbouncer/pg_hba.conf): Pgbouncer hba authentication file.
* VAR_param_unix_socket_dir (/run/pgbouncer): Pgbouncer Unix socket dir, used by both frontend and backend.
* VAR_param_listen_addr (*): Allowed client network addresses. Default set to allow all.

### Other runtime variables
* VAR_DATABASE_USERS: Comma separated list of database users.
* VAR_AUTH_HBA: Comma separated list of hba rules. Optional.
* VAR_param_&lt;parameter name&gt;: f ex VAR_param_auth_type.
* VAR_password&#95;file_&lt;user name from VAR_DATABASE_USERS&gt;: Path to file containing the password for named user.
* VAR_password_&lt;user name from VAR_DATABASE_USERS&gt;: The password for named user. Slightly less secure.
* VAR_ENCRYPT_PW: Set to "yes" to hash passwords with Argon2.

## Capabilities
Can drop all but SETPCAP, SETGID and SETUID.
