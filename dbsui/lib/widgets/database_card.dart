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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

// Project imports:
import 'package:dbsui/blocs/database/database.dart';
import 'package:dbsui/blocs/environments/environments.dart';
import 'package:dbsui/blocs/migrations/migrations.dart';
import 'package:dbsui/home/home.dart';
import 'package:dbsui/string_extensions.dart';
import 'package:dbsui/widgets/confirmation_button.dart';
import 'package:dbsui/widgets/operation_button.dart';
import 'package:dbsui/widgets/status_chip.dart';

class DatabaseCard extends StatelessWidget {
  DatabaseCard({this.version, this.name, this.allowForcedVersion});

  final int version;
  final String name;
  final bool allowForcedVersion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: BlocBuilder<DatabaseBloc, DatabaseState>(
        builder: (dbContext, dbState) {
          return BlocBuilder<OperationBloc, OperationState>(
              builder: (opContext, opState) {
            return Column(
              children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                              leading: Icon(Icons.storage),
                              title: SelectableText(
                                  "Database: ${name.toCapitalized()}"),
                              subtitle: SelectableText("Version: $version")),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: StatusChip(
                              dbVersion: dbState.version,
                              dbIsDirty: dbState.isDirty,
                              dbErrorMessage: dbState.errorMessage,
                              migrations: context
                                  .read<MigrationsBloc>()
                                  .state
                                  .migrations,
                            )),
                      ],
                    ),
                  ] +
                  (allowForcedVersion
                      ? <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(64, 0, 8, 0),
                            child: Container(
                              height: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                                child: Container(
                                  width: 160,
                                  height: 28,
                                  child: TextField(
                                    key: const Key(
                                        'forceVersion_versionInput_textField'),
                                    onChanged: (version) => context
                                        .read<OperationBloc>()
                                        .add(OperationForceVersionChanged(
                                            version)),
                                    decoration: InputDecoration(
                                      labelText: 'Version',
                                      errorText: opState.version.invalid
                                          ? 'Invalid version'
                                          : null,
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                                  child: ConfirmationButton(
                                    title: Text(
                                        "Database: ${context.read<EnvironmentsBloc>().state.selectedEnvironment.toCapitalized()}"),
                                    content: Text(
                                        "Does not perform migrations!!!\n\nForce your database to ${opState.forceVersion.asInt}?"),
                                    buttonBuilder: (context, onPressed) {
                                      return OperationButton(
                                        submitting:
                                            opState.submissionInProgress,
                                        allowForcedVersion: true,
                                        allowDowngrade: false,
                                        version: opState.forceVersion.asInt,
                                        opIsForcedVersion:
                                            opState.operation.value ==
                                                OperationType.forceVersion,
                                        opVersion: opState.operation.value ==
                                                OperationType.forceVersion
                                            ? opState.version.value
                                            : -1,
                                        dbVersion: -1,
                                        onPressed: onPressed,
                                      );
                                    },
                                    onPressed: opState.forceStatus.isValid
                                        ? () {
                                            context.read<OperationBloc>()
                                              ..add(OperationTypeChanged(
                                                  OperationType.forceVersion))
                                              ..add(OperationSubmitted());
                                          }
                                        : null,
                                  )),
                            ],
                          ),
                        ]
                      : <Widget>[]) +
                  (!(dbState.errorMessage?.isEmpty ?? true)
                      ? <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Theme.of(context).errorColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "Error: ${dbState.errorMessage}",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ]
                      : <Widget>[]) +
                  (!(opState.submissionError?.isEmpty ?? true)
                      ? <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Theme.of(context).errorColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "Error: ${opState.submissionError}",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ]
                      : <Widget>[]),
            );
          });
        },
      ),
    );
  }
}
