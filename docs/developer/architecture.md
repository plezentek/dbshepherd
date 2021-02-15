# ![DB Shepherd](images/dbshepherd.png) DB Shepherd Architecture

This is an overview of the architecture of the DB Shephard app.

# High Level
DB Shepherd is an http server written in Go.  It serves a GRPC API via standard
GRPC and with an embedded GRPC-Web proxy to allow servicing GRPC requests to
websites.  It also serves a static web app written in Dart and Flutter that
uses the API.

## GRPC API
In the `/api` directory lives the Proto3 GRPC API definition.  It is used both
by the server app and the Flutter UI.

## Go Server App
The Go Server app is structured as a [Cobra](https://github.com/spf13/cobra)
command that instantiates a Services implementation (local concept) via [Google
Wire](https://github.com/google/wire) dependency injection.  The Services
interface is just a lifecycle API allowing for the startup and graceful
shutdown of long-running code, like an HTTP server.

The current services that exist are the HTTP server, and the health service,
which is mostly symbolic in this release. In future versions, it will be
possible to do things like monitor memory usage, or database connections. For
now, it's mostly just a convenient web endpoint to let tools know that we're up
and serving requests.

In addition to services, there is a signal handler for watching for shutdown
requests, and an implementation for the GRPC API found in `/api`.

## Flutter UI
The Flutter app used [BLoC](https://bloclibrary.dev) for managing state. There
are three main BLoC's, one for maintaining the list of environments as well as
the currently selected environment. The second contains information about the
status of the database for the currently selected environment.  Finally, the
last BLoC is for tracking the list of migrations.

The interface is limited to a single page, which updates in response to the
three BLoCs.  It maintains it's own UI BLoC for managing the state of ongoing
operations, like performing migrations, or forcing a version.

# Packaging
Bazel packaging rules compile the flutter app and convert the files into an
importable Go module.  The constants in this Go module are then served as
static files over the web server.
