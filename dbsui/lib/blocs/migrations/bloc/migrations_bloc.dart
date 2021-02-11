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

part 'migrations_event.dart';
part 'migrations_state.dart';

class MigrationsBloc extends Bloc<MigrationsEvent, MigrationsState> {
  MigrationsBloc({
    @required this.migrateRepository,
    @required this.environmentsBloc,
  })  : assert(migrateRepository != null),
        assert(environmentsBloc != null),
        super(MigrationsState.unloaded) {
    envSub = environmentsBloc.listen((state) async {
      if (state.selectedEnvironment != "") {
        add(MigrationsRefreshRequested());
      }
    });
  }

  final EnvironmentsBloc environmentsBloc;
  StreamSubscription<EnvironmentsState> envSub;

  final MigrateRepository migrateRepository;

  @override
  Stream<MigrationsState> mapEventToState(
    MigrationsEvent event,
  ) async* {
    if (event is MigrationsRefreshRequested) {
      final migrations = await migrateRepository
          .listMigrations(environmentsBloc.state.selectedEnvironment);
      yield MigrationsState(migrations: migrations);
    } else if (event is MigrationSourceRequested) {
      final migration = await migrateRepository.getMigration(
          environmentsBloc.state.selectedEnvironment, event.version);
      yield state.copyWith(migration: migration);
    }
  }

  @override
  Future<void> close() {
    envSub.cancel();
    return super.close();
  }
}
