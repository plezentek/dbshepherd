# ![DB Shepherd](images/dbshepherd.png) DB Shepherd Configuration

DB Shepherd supports reading it’s configuration via flags, environment
variables, or a YAML-based configuration file, `.dbshepherd.yaml`.

For simple values, like the port to listen on, or the path to the TLS
certificate to use, they are specified exactly the same way across all three.
For complex values, however (the environments and the users), care must be
taken to use the correct formatting because of limitations in passing multiple
values via flags or environment variables.

### Generating bcrypt hashes

DB Shepherd uses bcrypt hashes.  One simple way to generate them is to use
`htpasswd` from the apache2-utils package. `htpasswd -bnBC 10 “” foobar | tr -d :`

### Flags
To specify multiple users or multiple environments, just specify the flag
multiple times on the command line, like `--user 'bob: pass' --user 'alice: pass'`

| Name   | Descriptions                              | Default                | Example                                                                     |
| :--:   | :----------:                              | :-----:                | :-----:                                                                     |
| config | Path to the configuration file            | $HOME/.dbshepherd.yaml |                                                                             |
| port   | The TCP port to listen on                 | 8080                   |                                                                             |
| cert   | The TLS certificate to use                | *none*                 | /certs/server.crt                                                           |
| key    | The TLS key to use                        | *none*                 | /certs/server.key                                                           |
| user   | User and bcrypt hash (use multiple times) | *none*                 | --user ‘bob: $2y$10$Y7dxOOsSEGR3jO2heIEnrOUE8djhD2XE7oSmkbo6tHv8vb/oKiDt.’  |
| env    | Database environment for migrations       | *none*                 | --env ‘prod: [files:///schemas/prod, postgres://user:password@host/dbname]’ |

### Environment Variables
All environment variables are specified with the prefix 'DBS_'. Because you can
only specify one value for an environment variable, for the complex values
users and environments, we accept inline YAML lists.

| Name             | Descriptions                                      | Default | Example                                                                     |
| :--:             | :----------:                                      | :-----: | :-----:                                                                     |
| DBS_PORT         | The TCP port to listen on                         | 8080    | DBS_PORT=443                                                                |
| DBS_CERT         | The TLS certificate to use                        | *none*  | DBS_CERT=/certs/server.crt                                                  |
| DBS_KEY          | The TLS key to use                                | *none*  | DBS_KEY=/certs/server.key                                                   |
| DBS_USERS        | List of users and bcryps hashes                   | *none*  | DBS_USERS='[username: passwordhash, username2: passwordhash2]'              |
| DBS_ENVIRONMENTS | List of environments and source and database URIs | *none*  | DBS_ENVIRONMENTS=DBS_ENVIRONMENTS='[prod: [uri1, uri2], dev: [uri3, uri4]]' |

### Config File
Top-level sections are optional, and will use default values when appropriate.
Here is a full example:
```yaml
environments:
  prod:
  - file:///schemas/prod
  - postgres://user:password@host/dbname
  dev:
  - file:///schemas/dev
  - sqlite3:///db/dev_database.sqlite
users:
  alice: $2y$10$JBjPXCFnK0n/L50yHTLxDO2tDa/v22ypB.cy7H/dfBCnX28zA7RBi
  bob: $2y$10$Y7dxOOsSEGR3jO2heIEnrOUE8djhD2XE7oSmkbo6tHv8vb/oKiDt.
port: 8080  # The default value
# If both cert and key are not supplied, DB Shepherd will serve http
cert: /certs/server.crt
key: /certs/server.key
```
