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

part of 'migrations_bloc.dart';

class MigrationsState extends Equatable {
  const MigrationsState({
    this.migrations,
  });

  final List<Migration> migrations;

  MigrationsState copyWith({
    List<Migration> migrations,
    Migration migration,
  }) {
    var newList = migrations ?? this.migrations;
    if (migration != null) {
      for (int i = 0; i < newList.length; ++i) {
        if (newList[i].version == migration.version) {
          return MigrationsState(
              migrations: new List<Migration>.from(newList)
                ..replaceRange(i, i + 1, [migration]));
        }
      }
    }
    return MigrationsState(
      migrations: newList,
    );
  }

  Migration getVersion(int version) {
    if (this.migrations == null) {
      return null;
    }

    for (int i = 0; i < this.migrations.length; ++i) {
      if (this.migrations[i].version == version) {
        return this.migrations[i];
      }
    }

    return null;
  }

  static const unloaded = MigrationsState();

  @override
  List<Object> get props => [migrations];
}
