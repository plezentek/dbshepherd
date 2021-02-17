# ![DB Shepherd](/images/dbshepherd.png) DB Shepherd Build Process

DB Shepherd uses [Bazel](https://bazel.build) for the build system.  There are
not yet bazel rules for [Flutter](https://flutter.dev) yet, so you also have to
have a local Flutter install, which means the build is not hermetic.

## Preparing your machine for development
1. Install [bazelisk](https://github.com/bazelbuild/bazelisk), the
   self-updating bazel install.
2. Install [Flutter](https://flutter.dev/docs/get-started/install).
3. Set your Flutter install to the beta channel[^1].

[^1]: As of 2021/02/13, Flutter web is only available via the beta channel.
  See instructions at [Flutter Web](https://flutter.dev/web)

## Building
The full server can be built with the following command:
```bash
bazel build //:dbshepherd
```

### Build flavors
You can also build one of the following release flavors:

| Flavor        | Description                                      | Bazel Command                              |
| :----:        | :---------:                                      | :-----------:                              |
| full          | All available Database and Source drivers        | `bazel build //:dbshepherd`                |
| Postgres Lite | Postgres Database driver with file Source driver | `bazel build //:dbshepherd_postgres_files` |
| Sqlite Lite   | Sqlite Database driver with file Source driver   | `bazel build //:dbshepherd_sqlite_files`   |
| Dev           | All drivers, but no embedded Flutter UI          | `bazel build //:dbshepherd_dev`            |

## Development
To make it easier to work on developing DB Shepherd, you can use the Dev build
flavor, and then run flutter in debug mode connected to your local DB Shepherd
instance:

```bash
flutter run -d web-server --dart-define=api_server=localhost:8080
```
