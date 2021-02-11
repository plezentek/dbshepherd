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
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:migrate_repository/migrate_repository.dart';

// Project imports:
import 'package:dbsui/blocs/environments/environments.dart';
import 'package:dbsui/blocs/database/database.dart';
import 'package:dbsui/home/home.dart';

part 'operation_event.dart';
part 'operation_state.dart';

class OperationBloc extends Bloc<OperationEvent, OperationState> {
  OperationBloc(
      {@required this.migrateRepository,
      @required this.databaseBloc,
      @required this.environmentsBloc})
      : assert(migrateRepository != null),
        assert(databaseBloc != null),
        assert(environmentsBloc != null),
        super(OperationState());

  final MigrateRepository migrateRepository;
  final DatabaseBloc databaseBloc;
  final EnvironmentsBloc environmentsBloc;

  @override
  Stream<OperationState> mapEventToState(OperationEvent event) async* {
    if (event is OperationSetVersionChanged) {
      final version = DataVersion.dirty(event.version);
      yield state.copyWith(
          version: version,
          setStatus: Formz.validate([version, state.operation]));
    } else if (event is OperationForceVersionChanged) {
      final version = InputVersion.dirty(event.version);
      yield state.copyWith(
          forceVersion: version,
          forceStatus: Formz.validate([version, state.operation]));
    } else if (event is OperationTypeChanged) {
      final operation = Operation.dirty(event.opType);
      yield state.copyWith(
          operation: operation,
          setStatus: Formz.validate([state.version, state.operation]),
          forceStatus: Formz.validate([state.forceVersion, state.operation]));
    } else if (event is OperationSubmitted) {
      if (state.operation.value == OperationType.setVersion) {
        yield state.copyWith(setStatus: FormzStatus.submissionInProgress);
        try {
          final response = await migrateRepository.setVersion(
            environmentsBloc.state.selectedEnvironment,
            state.version.value,
          );
          if (response.successful) {
            yield state.copyWith(
                setStatus: FormzStatus.submissionSuccess, submissionError: "");
          } else {
            yield state.copyWith(
                setStatus: FormzStatus.submissionFailure,
                submissionError: response.errorMessage);
          }
        } catch (e) {
          yield state.copyWith(
              setStatus: FormzStatus.submissionFailure, submissionError: e);
        }
      } else if (state.operation.value == OperationType.forceVersion) {
        yield state.copyWith(forceStatus: FormzStatus.submissionInProgress);
        try {
          final response = await migrateRepository.forceMarkVersion(
            environmentsBloc.state.selectedEnvironment,
            state.forceVersion.asInt,
          );
          if (response.successful) {
            yield state.copyWith(
                forceStatus: FormzStatus.submissionSuccess,
                submissionError: "");
          } else {
            yield state.copyWith(
                forceStatus: FormzStatus.submissionFailure,
                submissionError: response.errorMessage);
          }
        } catch (e) {
          yield state.copyWith(
              forceStatus: FormzStatus.submissionFailure, submissionError: e);
        }
      }
      databaseBloc.add(DatabaseRefreshRequested());
    }
  }
}
