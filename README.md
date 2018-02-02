# pgbouncer-alpine
A minimal docker image with Pgbouncer. Listens by default on port 6432.

## Environment variables
### pre-set variables (can be set at runtime)
* CONFIG_FILE (/etc/pgbouncer/pgbouncer.ini): Pgbouncer configuration file.
* AUTH_FILE (/etc/pgbouncer/userlist.txt): Pgbouncer authentication file.
* AUTH_HBA_FILE (/etc/pgbouncer/pg_hba.conf): Pgbouncer hba authentication file.
* UNIX_SOCKET_DIR (/var/run/pgbouncer): Pgbouncer Unix socket dir, used by both frontend and backend.
* DATABASES (*=port=5432): Comma separated list of backend databases. Default set to only read from Unix socket.
* LISTEN_ADDR (*): Allowed client network addresses. Default set to allow all.

### Optional runtime variables
* AUTH_TYPE: One of pam, hba, cert, mb5, plain, trust, any.
* AUTH_HBA: Comma separated list of hba rules.
* SERVER_RESET_QUERY: See Pgbouncer documentation.
* CLIENT_TLS_SSLMODE: TLS mode to use for connections from clients. One of disable, allow, prefer, require, verify-ca, verify-full.
* CLIENT_TLS_KEY_FILE: Private key for PgBouncer to accept client connections.
* CLIENT_TLS_CERT_FILE: Certificate for private key.
* CLIENT_TLS_CA_FILE: Root certificate file to validate client certificates.
* ADDITIONAL_CONFIGURATION: Comma separated list of pgbouncer configurations.

## Capabilities
### Can drop
* ALL
