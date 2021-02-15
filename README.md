# ![DB Shepherd](/images/dbshepherd.png) DB Shepherd - Database Migration Server

DB Shepherd is an open source web console for managing your database's
migrations.

DB Shephard is a Go-based web server that serves a GRPC API for database
migrations as well as a web application built upon the API using Flutter.  It
is built using the [Golang Migrate](https://github.com/golang-migrate/migrate)
library, which means that is has support for reading migrations from many
sources, and managing many different kinds of databases.

DB Shepherd supports running from a standalone binary, from the [DB Shephard
Docker Image](https://hub.docker.com/r/plezentek/dbshepherd), or via the
provided Kubernetes manifests.

![Health Server](/images/healthy.png)

## Table of Contents
1. [Leaderboard](#leaderboard)
2. [Setup](#setup)
3. [Configuration](#configuration)
4. [Documentation](#documentation)
5. [Screenshots](#screenshots)
6. [Versioning](#versioning)
7. [Bounties](#bounties)

## Leaderboard
This is a list of contributors and their accomplishments

+1.0.0 Douglas Mayle - Initial Release

## Setup
If you want to install the software locally (for development, or with your own
packaging) then get the latest release from
https://github.com/plezentek/dbshepherd/releases.

There are also Docker images available at https://hub.docker.com/r/plezentek/dbshepherd.

## Configuration
DB Shepherd supports reading it’s configuration via flags, environment
variables, or a YAML-based configuration file, `.dbshepherd.yaml`.

For simple values, like the port to listen on, or the path to the TLS
certificate to use, they are specified exactly the same way across all three.
For complex values, however (the environments and the users), care must be
taken to use the correct formatting because of limitations in passing multiple
values via flags or environment variables.

For full information on all of the configuration possibilities, please check
out the [Configuration Documentation](docs/configuration.md).

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


## Documentation
Full documentation can be found in the [docs directory](docs/README.md).

## Screenshots
### Up-to-date Server
![Healthy Server](/images/healthy.png)

### Upgrade available
![Upgrage Available](/images/upgrade_available.png)

### Syntax highlighting of migration source
![Syntax Highlighting](/images/upgrade_source.png)

### Confirmation before upgrading
![Confirmation Dialong](/images/confirmation.png)

### Advanced Controls
![Advanced Controls](/images/advanced_controls.png)

### Out-of-date Server
![Out-of-date Server](/images/out_of_date.png)

## Versioning
DB Shepherd uses Gamever for versioning, which means we publish bounties for
features and maintain a leaderboard for contributors.  See [Versioning
Documentation](docs/versioning.md) for more details.

## Bounties (Roadmap)
The bounties acts as a sort of roadmap for future development.  Finish one of
the bounties to earn Gamever points and put yourself on the
[Leaderboard](#leaderboard)

### Major Versions
 * +1.0.0 Add support for long-running migrations
   * +0.1.0 Update GRPC API with calls to check for running migration status,
     and to cancel migration in advance mode
   * +0.1.0 Add backend server support for these calls
   * +0.1.0 Add frontend UI support for long-running migrations
   * +0.0.1 Add a detailed design doc breaking this down in a more detailed
     manner.

### Minor Versions
 * +0.1.0 Switch to koanf to cut 8MB from server binary
 * +0.1.0 Add translation support
 * +0.1.0 Detect 401 response from GRPC in cached web-app and request user to
   refresh to login again
 * +0.1.0 Design: Create a material design color palette unique to DB Shepherd
 * +0.1.0 Switch flutter embed rule `go_embed_data` to use zip of build outputs

