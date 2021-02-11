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
import 'package:shimmer_animation/shimmer_animation.dart';

// Project imports:
import 'package:dbsui/blocs/database/database.dart';
import 'package:dbsui/blocs/migrations/migrations.dart';
import 'package:dbsui/widgets/database_card.dart';
import 'package:dbsui/widgets/version_card.dart';

class HomeView extends StatelessWidget {
  HomeView({this.selectedEnvironment, this.showAdvancedControls});

  final String selectedEnvironment;
  final bool showAdvancedControls;

  Widget build(BuildContext context) {
    return SizedBox(
      width: 960,
      child: BlocBuilder<MigrationsBloc, MigrationsState>(
        builder: (context, migrationsState) {
          return ListView(
            children: <Widget>[
                  BlocBuilder<DatabaseBloc, DatabaseState>(
                    builder: (context, databaseState) {
                      return DatabaseCard(
                          name: selectedEnvironment,
                          version: databaseState.version,
                          allowForcedVersion: showAdvancedControls);
                    },
                  ),
                ] +
                (migrationsState.migrations != null
                    ? migrationsState.migrations.map((migration) {
                        return Padding(
                          padding: EdgeInsets.only(left: 64),
                          child: VersionCard(
                            version: migration.version,
                            identifier: migration.identifier,
                            allowDowngrade: showAdvancedControls,
                            migration: migration,
                          ),
                        );
                      }).toList()
                    : <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 64),
                          child: Card(
                              child: Shimmer(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child:
                                          Container(color: Colors.grey[300])),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 0, 0, 8),
                                          child: Container(
                                              height: 16,
                                              color: Colors.grey[300]),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 0, 80, 0),
                                          child: Container(
                                              height: 16,
                                              color: Colors.grey[300]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        )
                      ]),
          );
        },
      ),
    );
  }
}
