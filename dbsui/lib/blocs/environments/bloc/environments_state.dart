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

class EnvironmentsState extends Equatable {
  const EnvironmentsState({
    this.environments,
    this.selectedEnvironment,
  });

  final List<String> environments;
  final String selectedEnvironment;

  EnvironmentsState copyWith({
    List<String> environments,
    String selectedEnvironment,
  }) {
    if (environments != null) {
      if (selectedEnvironment != null &&
          environments.contains(selectedEnvironment)) {
        return EnvironmentsState(
            environments: environments,
            selectedEnvironment: selectedEnvironment);
      } else if (environments.contains(this.selectedEnvironment)) {
        return EnvironmentsState(
            environments: environments,
            selectedEnvironment: this.selectedEnvironment);
      } else {
        return EnvironmentsState(
            environments: environments, selectedEnvironment: environments[0]);
      }
    }
    if (selectedEnvironment != null &&
        this.environments.contains(selectedEnvironment)) {
      return EnvironmentsState(
          environments: this.environments,
          selectedEnvironment: selectedEnvironment);
    }
    return EnvironmentsState(
      environments: this.environments,
      selectedEnvironment: this.selectedEnvironment,
    );
  }

  static const unloaded =
      EnvironmentsState(environments: [""], selectedEnvironment: "");

  String get defaultEnvironment => this.environments?.first ?? "";

  @override
  List<Object> get props => [environments, selectedEnvironment];
}
