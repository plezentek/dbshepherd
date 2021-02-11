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
import 'package:migrate_repository/migrate_repository.dart';

// Project imports:
import 'package:dbsui/blocs/database/database.dart';
import 'package:dbsui/blocs/environments/environments.dart';
import 'package:dbsui/blocs/migrations/migrations.dart';
import 'package:dbsui/home/home.dart';
import 'package:dbsui/string_extensions.dart';
import 'package:dbsui/widgets/confirmation_button.dart';
import 'package:dbsui/widgets/lazy_source_view.dart';
import 'package:dbsui/widgets/operation_button.dart';

enum SourceShown { none, up, down }

class VersionCard extends StatefulWidget {
  VersionCard(
      {this.version, this.identifier, this.allowDowngrade, this.migration});

  final int version;
  final String identifier;
  final bool allowDowngrade;
  final Migration migration;

  @override
  VersionCardState createState() => VersionCardState();
}

class VersionCardState extends State<VersionCard> {
  SourceShown shown = SourceShown.none;

  void requestSource(BuildContext context) {
    if ((shown == SourceShown.up
            ? widget.migration.sourceUp
            : widget.migration.sourceDown) ==
        null) {
      context
          .read<MigrationsBloc>()
          .add(MigrationSourceRequested(widget.version));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        ListTile(
            leading: Icon(Icons.source),
            title: SelectableText("Version: ${widget.version}"),
            subtitle: Text(widget.identifier)),
        Padding(
          padding: EdgeInsets.fromLTRB(64, 0, 8, 0),
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(64, 8, 0, 8),
              child: TextButton.icon(
                icon: Icon(shown == SourceShown.up
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right),
                onPressed: () {
                  setState(() {
                    shown = shown == SourceShown.up
                        ? SourceShown.none
                        : SourceShown.up;
                  });
                },
                label: Text("Up Migration"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: TextButton.icon(
                icon: Icon(shown == SourceShown.down
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right),
                onPressed: () {
                  setState(() {
                    shown = shown == SourceShown.down
                        ? SourceShown.none
                        : SourceShown.down;
                  });
                  return true;
                },
                label: Text("Down Migration"),
              ),
            ),
            Expanded(child: Container()),
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: BlocBuilder<DatabaseBloc, DatabaseState>(
                builder: (dbContext, dbState) {
                  return BlocBuilder<OperationBloc, OperationState>(
                      builder: (opContext, opState) {
                    return ConfirmationButton(
                      title: Text(
                          "Database: ${context.read<EnvironmentsBloc>().state.selectedEnvironment.toCapitalized()}"),
                      content: Text(
                          "Measure twice, cut once.\n\nApply ${widget.version} to your database?"),
                      buttonBuilder: (context, onPressed) {
                        return OperationButton(
                          submitting: opState.submissionInProgress,
                          allowForcedVersion: false,
                          allowDowngrade: widget.allowDowngrade,
                          version: widget.version,
                          opIsForcedVersion: opState.operation.value ==
                              OperationType.forceVersion,
                          opVersion: opState.operation.value ==
                                  OperationType.setVersion
                              ? opState.version.value
                              : -1,
                          dbVersion: dbState.version,
                          onPressed: onPressed,
                        );
                      },
                      onPressed: () {
                        context.read<OperationBloc>()
                          ..add(OperationSetVersionChanged(widget.version))
                          ..add(OperationTypeChanged(OperationType.setVersion))
                          ..add(OperationSubmitted());
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
        BlocBuilder<MigrationsBloc, MigrationsState>(
          builder: (context, migrationsState) {
            return shown == SourceShown.none
                ? Container()
                : LazySourceView(
                    source: shown == SourceShown.up
                        ? widget.migration.sourceUp
                        : widget.migration.sourceDown,
                    onMissing: () {
                      requestSource(context);
                    },
                  );
          },
        ),
      ],
    ));
  }
}
