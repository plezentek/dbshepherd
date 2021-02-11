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

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:migrate_repository/migrate_repository.dart';

part 'environments_event.dart';
part 'environments_state.dart';

class EnvironmentsBloc
    extends HydratedBloc<EnvironmentsEvent, EnvironmentsState> {
  EnvironmentsBloc({
    @required this.migrateRepository,
  })  : assert(migrateRepository != null),
        super(EnvironmentsState.unloaded);

  final MigrateRepository migrateRepository;

  @override
  Stream<EnvironmentsState> mapEventToState(
    EnvironmentsEvent event,
  ) async* {
    final currentState = state;
    if (event is EnvironmentInitial) {
      final environments = await migrateRepository.loadEnvironments();
      yield currentState.copyWith(environments: environments);
    } else if (event is EnvironmentSelected) {
      yield currentState.copyWith(selectedEnvironment: event.environment);
    } else {
      yield currentState;
    }
  }

  @override
  EnvironmentsState fromJson(Map<String, dynamic> json) {
    return EnvironmentsState(
        selectedEnvironment: json['selected'],
        environments: json['environments']);
  }

  @override
  Map<String, dynamic> toJson(EnvironmentsState state) {
    return {
      'selected': state.selectedEnvironment,
      'environments': state.environments
    };
  }
}
