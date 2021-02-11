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

part of 'environments_bloc.dart';

abstract class EnvironmentsEvent extends Equatable {
  const EnvironmentsEvent();

  @override
  List<Object> get props => [];
}

class EnvironmentInitial extends EnvironmentsEvent {}

class EnvironmentSelected extends EnvironmentsEvent {
  const EnvironmentSelected(this.environment);

  final String environment;

  @override
  List<Object> get props => [environment];
}
