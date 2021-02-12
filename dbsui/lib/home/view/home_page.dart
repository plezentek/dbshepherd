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
import 'package:dbsui/home/home.dart';
import 'package:dbsui/widgets/environments_dropdown.dart';

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EnvironmentsBloc>(context).add(EnvironmentInitial());
  }

  bool showAdvancedControls = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OperationBloc>(
      create: (context) => OperationBloc(
        migrateRepository: context.read<MigrateRepository>(),
        databaseBloc: context.read<DatabaseBloc>(),
        environmentsBloc: context.read<EnvironmentsBloc>(),
      ),
      child: GestureDetector(
        onTap: () {
          // Having a page-wide GestureDetector allows us to unfocus the
          // version text field in advanced database controls
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: BlocBuilder<EnvironmentsBloc, EnvironmentsState>(
          builder: (context, environmentState) {
            return Scaffold(
              appBar: AppBar(
                leading: Image(image: AssetImage('images/dbshepherd.png')),
                title: const Text('DB Shepherd'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: EnvironmentsDropdown(
                        selectedEnvironment:
                            environmentState.selectedEnvironment,
                        defaultEnvironment: environmentState.defaultEnvironment,
                        environments: environmentState.environments,
                        onChanged: (String newEnvironment) {
                          context
                              .read<EnvironmentsBloc>()
                              .add(EnvironmentSelected(newEnvironment));
                        }),
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext bc) => [
                      PopupMenuItem(
                        // Like HomePage, PopupMenuItem is a StatefulWidget, so
                        // we need a StatefulBuilder so that we can update both
                        // the PopupMenuItem and the other HomePage
                        child: StatefulBuilder(
                          builder: (BuildContext _, StateSetter innerState) {
                            return SwitchListTile(
                                title: const Text("Advanced"),
                                value: showAdvancedControls,
                                onChanged: (bool newVal) =>
                                    setState(() => innerState(() {
                                          showAdvancedControls = newVal;
                                        })));
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
              body: Center(
                child: HomeView(
                  selectedEnvironment: environmentState.selectedEnvironment,
                  showAdvancedControls: showAdvancedControls,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
