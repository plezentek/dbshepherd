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

part of 'operation_bloc.dart';

class OperationState extends Equatable {
  const OperationState({
    this.setStatus = FormzStatus.pure,
    this.forceStatus = FormzStatus.pure,
    this.operation = const Operation.pure(),
    this.version = const DataVersion.pure(),
    this.forceVersion = const InputVersion.pure(),
    this.submissionError,
  });

  final FormzStatus setStatus;
  final FormzStatus forceStatus;
  final Operation operation;
  final DataVersion version;
  final InputVersion forceVersion;
  final String submissionError;

  OperationState copyWith({
    FormzStatus setStatus,
    FormzStatus forceStatus,
    Operation operation,
    DataVersion version,
    InputVersion forceVersion,
    String submissionError,
  }) {
    return OperationState(
      setStatus: setStatus ?? this.setStatus,
      forceStatus: forceStatus ?? this.forceStatus,
      operation: operation ?? this.operation,
      version: version ?? this.version,
      forceVersion: forceVersion ?? this.forceVersion,
      submissionError: submissionError ?? this.submissionError,
    );
  }

  bool get submissionInProgress {
    return setStatus == FormzStatus.submissionInProgress ||
        forceStatus == FormzStatus.submissionInProgress;
  }

  @override
  List<Object> get props => [
        setStatus,
        forceStatus,
        operation,
        version,
        forceVersion,
        submissionError
      ];
}
