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
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc_web.dart';
// import 'package:grpc/grpc.dart';

// Project imports:
import 'generated/migrate.pbgrpc.dart' as pb;
import 'models/models.dart';

class MigrateRepository {
  String apiServer = const String.fromEnvironment("api_server");
  MigrateRepository() {
    final uri =
        (apiServer?.isEmpty ?? true) ? Uri.base : Uri.http(apiServer, '');
    this.stub = pb.MigrateClient(GrpcWebClientChannel.xhr(uri));
  }

  pb.MigrateClient stub;

  Future<List<String>> loadEnvironments() async {
    final request = pb.Empty();
    try {
      final response = await stub.listEnvironments(request);
      return response.environments.map((val) => val.name).toList();
    } catch (e) {
      return Future.value([]);
    }
  }

  Future<Database> getDatabase(String environment) async {
    final request = pb.Environment()..name = environment;
    try {
      final response = await stub.getDatabaseVersion(request);
      return Future.value(Database(
          version: response.version.toInt(),
          isDirty: response.isDirty,
          errorMessage: response.error));
    } catch (e) {
      return Future.value(Database.unloaded);
    }
  }

  Future<List<Migration>> listMigrations(String environment) async {
    final request = pb.Environment()..name = environment;
    try {
      final response = await stub.listMigrations(request);
      return response.migrations.reversed
          .map((val) => Migration(
              version: val.version.toInt(),
              identifierUp: val.identifierUp,
              identifierDown: val.identifierDown))
          .toList();
    } catch (e) {
      return Future.value([]);
    }
  }

  Future<Migration> getMigration(String environment, int version) async {
    final request = pb.GetMigrationRequest()
      ..environment = environment
      ..version = Int64(version);
    try {
      final response = await stub.getMigration(request);
      return Migration(
          version: response.migration.version.toInt(),
          identifierUp: response.migration.identifierUp,
          identifierDown: response.migration.identifierDown,
          sourceUp: response.migration.sourceUp,
          sourceDown: response.migration.sourceDown);
    } catch (e) {
      return Future.value(Migration.unloaded);
    }
  }

  Future<ResponseStatus> setVersion(String environment, int version) async {
    final request = pb.SetVersionRequest()
      ..environment = environment
      ..version = Int64(version);
    try {
      final response = await stub.setVersion(request);
      return ResponseStatus(
          version: Int64(version),
          successful: response.successful,
          errorMessage: response.error);
    } catch (e) {
      return ResponseStatus(
          version: Int64(version), successful: false, errorMessage: e);
    }
  }

  Future<ResponseStatus> forceMarkVersion(
      String environment, int version) async {
    final request = pb.ForceMarkVersionRequest()
      ..environment = environment
      ..version = Int64(version);
    try {
      final response = await stub.forceMarkVersion(request);
      return ResponseStatus(
          version: Int64(version),
          successful: response.successful,
          errorMessage: response.error);
    } catch (e) {
      return ResponseStatus(
          version: Int64(version), successful: false, errorMessage: e);
    }
  }
}
