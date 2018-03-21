**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# pgbouncer-alpine
A secure and minimal docker image with Pgbouncer. Listens by default on port 6432.

## Pre-set environment variables (can be set at runtime)
* REV_DATABASES (*=port=5432): Comma separated list of backend databases. Default set to only read from Unix socket.
### Default Pgbouncer configuration
* REV_param_auth_file (/etc/pgbouncer/userlist.txt): Pgbouncer authentication file.
* REV_param_auth_hba_file (/etc/pgbouncer/pg_hba.conf): Pgbouncer hba authentication file.
* REV_param_unix_socket_dir (/run/pgbouncer): Pgbouncer Unix socket dir, used by both frontend and backend.
* REV_param_listen_addr (*): Allowed client network addresses. Default set to allow all.

## Runtime environment variables
* REV_DATABASE_USERS: Comma separated list of database users.
* REV_AUTH_HBA: Comma separated list of hba rules. Optional.
### Pgbouncer configuration
* REV_param_&lt;parameter name&gt;: f ex param_auth_type.
### Database user configuration
* REV_password&#95;file_&lt;user name from DATABASE_USERS&gt;: Path to file containing the password for named user. **Note! This file will be deleted unless write protected.**
* REV_password_&lt;user name from DATABASE_USERS&gt;: The password for named user. Slightly less secure.

## Capabilities
Can drop all but CHOWN, SETGID and SETUID.
