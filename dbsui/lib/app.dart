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
import 'blocs/database/database.dart';
import 'blocs/environments/environments.dart';
import 'blocs/migrations/migrations.dart';
import 'home/home.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MigrateRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EnvironmentsBloc>(
            create: (context) => EnvironmentsBloc(
                migrateRepository: context.read<MigrateRepository>()),
          ),
          BlocProvider<DatabaseBloc>(
            create: (context) => DatabaseBloc(
                migrateRepository: context.read<MigrateRepository>(),
                environmentsBloc: context.read<EnvironmentsBloc>()),
          ),
          BlocProvider<MigrationsBloc>(
            create: (context) => MigrationsBloc(
                migrateRepository: context.read<MigrateRepository>(),
                environmentsBloc: context.read<EnvironmentsBloc>()),
          ),
        ],
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  AppView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AppViewState createState() => AppViewState();
}

class AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (_) => HomePage.route(),
    );
  }
}
