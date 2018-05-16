**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# pgbouncer-alpine
A secure and minimal docker image with Pgbouncer. Listens by default on port 6432.

## Pre-set environment variables (can be set at runtime)
* VAR_DATABASES (*=port=5432): Comma separated list of backend databases. Default set to only read from Unix socket.
### Default Pgbouncer configuration
* VAR_param_auth_file (/etc/pgbouncer/userlist.txt): Pgbouncer authentication file.
* VAR_param_auth_hba_file (/etc/pgbouncer/pg_hba.conf): Pgbouncer hba authentication file.
* VAR_param_unix_socket_dir (/run/pgbouncer): Pgbouncer Unix socket dir, used by both frontend and backend.
* VAR_param_listen_addr (*): Allowed client network addresses. Default set to allow all.

## Runtime environment variables
* VAR_DATABASE_USERS: Comma separated list of database users.
* VAR_AUTH_HBA: Comma separated list of hba rules. Optional.
### Pgbouncer configuration
* VAR_param_&lt;parameter name&gt;: f ex VAR_param_auth_type.
### Database user configuration
* VAR_password&#95;file_&lt;user name from VAR_DATABASE_USERS&gt;: Path to file containing the password for named user.
* VAR_password_&lt;user name from VAR_DATABASE_USERS&gt;: The password for named user. Slightly less secure.

## Capabilities
Can drop all but CHOWN, FOWNER, SETGID and SETUID.
