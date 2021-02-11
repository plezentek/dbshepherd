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

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:migrate_repository/migrate_repository.dart';

// Project imports:
import 'package:dbsui/blocs/environments/environments.dart';

part 'database_event.dart';
part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  DatabaseBloc({
    @required this.migrateRepository,
    @required this.environmentsBloc,
  })  : assert(migrateRepository != null),
        assert(environmentsBloc != null),
        super(const DatabaseState()) {
    envSub = environmentsBloc.listen((state) async {
      if (state.selectedEnvironment != "") {
        add(DatabaseRefreshRequested());
      }
    });
  }

  final EnvironmentsBloc environmentsBloc;
  StreamSubscription<EnvironmentsState> envSub;

  final MigrateRepository migrateRepository;

  @override
  Stream<DatabaseState> mapEventToState(
    DatabaseEvent event,
  ) async* {
    if (event is DatabaseRefreshRequested) {
      final db = await migrateRepository
          .getDatabase(environmentsBloc.state.selectedEnvironment);
      yield DatabaseState(
          version: db.version,
          isDirty: db.isDirty,
          errorMessage: db.errorMessage);
    }
  }

  @override
  Future<void> close() {
    envSub.cancel();
    return super.close();
  }
}
