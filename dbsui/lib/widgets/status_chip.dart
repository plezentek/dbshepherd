// Copyright 2021 Plezentek, Inc. All rights reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:migrate_repository/migrate_repository.dart';

enum StatusType { incomplete, good, warning, error }

class StatusChip extends StatelessWidget {
  factory StatusChip({
    int dbVersion,
    bool dbIsDirty,
    String dbErrorMessage,
    List<Migration> migrations,
  }) {
    var status = StatusType.error;
    if (migrations == null || dbVersion == null) {
      status = StatusType.incomplete;
    } else if (dbIsDirty || !(dbErrorMessage?.isEmpty ?? true)) {
      status = StatusType.error;
    } else if (migrations.length < 1 || migrations[0].version == dbVersion) {
      status = StatusType.good;
    } else if (-1 ==
        migrations.indexWhere((mgrn) => mgrn.version == dbVersion)) {
      status = StatusType.error;
    } else if (migrations[1].version == dbVersion) {
      status = StatusType.warning;
    }
    String statusError;
    if (status == StatusType.error) {
      if (!(dbErrorMessage?.isEmpty ?? true)) {
        statusError = "Migration Error";
      } else if (dbIsDirty) {
        statusError = "Failed Migration";
      } else if (migrations.length > 0 && dbVersion > migrations[0].version) {
        statusError = "Version newer than all migrations";
      } else if (-1 ==
          migrations.indexWhere((mgrn) => mgrn.version == dbVersion)) {
        statusError = "Invalid version";
      } else {
        statusError = "Out of date";
      }
    }
    return StatusChip._(
      dbVersion: dbVersion,
      dbIsDirty: dbIsDirty,
      dbErrorMessage: dbErrorMessage,
      migrations: migrations,
      status: status,
      statusError: statusError,
    );
  }

  StatusChip._({
    this.dbVersion,
    this.dbIsDirty,
    this.dbErrorMessage,
    this.migrations,
    this.status,
    this.statusError,
  });

  final int dbVersion;
  final bool dbIsDirty;
  final String dbErrorMessage;
  final List<Migration> migrations;
  final StatusType status;
  final String statusError;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: status == StatusType.incomplete
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(
              status == StatusType.error
                  ? Icons.error
                  : status == StatusType.warning
                      ? Icons.build_circle
                      : Icons.verified,
              color: Theme.of(context).secondaryHeaderColor,
            ),
      label: Text(status == StatusType.incomplete
          ? "Loading Status"
          : status == StatusType.warning
              ? "Upgrade available"
              : status == StatusType.good
                  ? "Up to date"
                  : statusError),
      backgroundColor: status == StatusType.incomplete
          ? Colors.grey[600]
          : status == StatusType.good
              ? Colors.green
              : status == StatusType.warning
                  ? Colors.orange[800]
                  : Theme.of(context).errorColor,
      labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
    );
  }
}
