# ![DB Shepherd](/images/dbshepherd.png) DB Shepherd Binary Build Rules

This directory contains the Bazel build rules for the various build flavors,
one directory per flavor. This is because the go_binary executable is named
after the build rule, and build rule names are unique with a package/directory.
This allows us to create multiple build binaries each using the same binary
name, `dbshepherd`.
