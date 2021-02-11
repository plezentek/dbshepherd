///
//  Generated code. Do not modify.
//  source: migrate.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'migrate.pb.dart' as $0;
export 'migrate.pb.dart';

class MigrateClient extends $grpc.Client {
  static final _$listEnvironments =
      $grpc.ClientMethod<$0.Empty, $0.ListEnvironmentsResponse>(
          '/open.Migrate/ListEnvironments',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListEnvironmentsResponse.fromBuffer(value));
  static final _$getDatabaseVersion =
      $grpc.ClientMethod<$0.Environment, $0.GetDatabaseVersionResponse>(
          '/open.Migrate/GetDatabaseVersion',
          ($0.Environment value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetDatabaseVersionResponse.fromBuffer(value));
  static final _$listMigrations =
      $grpc.ClientMethod<$0.Environment, $0.ListMigrationsResponse>(
          '/open.Migrate/ListMigrations',
          ($0.Environment value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListMigrationsResponse.fromBuffer(value));
  static final _$getMigration =
      $grpc.ClientMethod<$0.GetMigrationRequest, $0.GetMigrationResponse>(
          '/open.Migrate/GetMigration',
          ($0.GetMigrationRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetMigrationResponse.fromBuffer(value));
  static final _$setVersion =
      $grpc.ClientMethod<$0.SetVersionRequest, $0.PerformMigrationResponse>(
          '/open.Migrate/SetVersion',
          ($0.SetVersionRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.PerformMigrationResponse.fromBuffer(value));
  static final _$forceMarkVersion = $grpc.ClientMethod<
          $0.ForceMarkVersionRequest, $0.PerformMigrationResponse>(
      '/open.Migrate/ForceMarkVersion',
      ($0.ForceMarkVersionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.PerformMigrationResponse.fromBuffer(value));

  MigrateClient($grpc.ClientChannel channel,
      {$grpc.CallOptions options,
      $core.Iterable<$grpc.ClientInterceptor> interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListEnvironmentsResponse> listEnvironments(
      $0.Empty request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$listEnvironments, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetDatabaseVersionResponse> getDatabaseVersion(
      $0.Environment request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$getDatabaseVersion, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMigrationsResponse> listMigrations(
      $0.Environment request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$listMigrations, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetMigrationResponse> getMigration(
      $0.GetMigrationRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$getMigration, request, options: options);
  }

  $grpc.ResponseFuture<$0.PerformMigrationResponse> setVersion(
      $0.SetVersionRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$setVersion, request, options: options);
  }

  $grpc.ResponseFuture<$0.PerformMigrationResponse> forceMarkVersion(
      $0.ForceMarkVersionRequest request,
      {$grpc.CallOptions options}) {
    return $createUnaryCall(_$forceMarkVersion, request, options: options);
  }
}

abstract class MigrateServiceBase extends $grpc.Service {
  $core.String get $name => 'open.Migrate';

  MigrateServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListEnvironmentsResponse>(
        'ListEnvironments',
        listEnvironments_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListEnvironmentsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.Environment, $0.GetDatabaseVersionResponse>(
            'GetDatabaseVersion',
            getDatabaseVersion_Pre,
            false,
            false,
            ($core.List<$core.int> value) => $0.Environment.fromBuffer(value),
            ($0.GetDatabaseVersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Environment, $0.ListMigrationsResponse>(
        'ListMigrations',
        listMigrations_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Environment.fromBuffer(value),
        ($0.ListMigrationsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetMigrationRequest, $0.GetMigrationResponse>(
            'GetMigration',
            getMigration_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetMigrationRequest.fromBuffer(value),
            ($0.GetMigrationResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetVersionRequest, $0.PerformMigrationResponse>(
            'SetVersion',
            setVersion_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetVersionRequest.fromBuffer(value),
            ($0.PerformMigrationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ForceMarkVersionRequest,
            $0.PerformMigrationResponse>(
        'ForceMarkVersion',
        forceMarkVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ForceMarkVersionRequest.fromBuffer(value),
        ($0.PerformMigrationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListEnvironmentsResponse> listEnvironments_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listEnvironments(call, await request);
  }

  $async.Future<$0.GetDatabaseVersionResponse> getDatabaseVersion_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Environment> request) async {
    return getDatabaseVersion(call, await request);
  }

  $async.Future<$0.ListMigrationsResponse> listMigrations_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Environment> request) async {
    return listMigrations(call, await request);
  }

  $async.Future<$0.GetMigrationResponse> getMigration_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetMigrationRequest> request) async {
    return getMigration(call, await request);
  }

  $async.Future<$0.PerformMigrationResponse> setVersion_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.SetVersionRequest> request) async {
    return setVersion(call, await request);
  }

  $async.Future<$0.PerformMigrationResponse> forceMarkVersion_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ForceMarkVersionRequest> request) async {
    return forceMarkVersion(call, await request);
  }

  $async.Future<$0.ListEnvironmentsResponse> listEnvironments(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.GetDatabaseVersionResponse> getDatabaseVersion(
      $grpc.ServiceCall call, $0.Environment request);
  $async.Future<$0.ListMigrationsResponse> listMigrations(
      $grpc.ServiceCall call, $0.Environment request);
  $async.Future<$0.GetMigrationResponse> getMigration(
      $grpc.ServiceCall call, $0.GetMigrationRequest request);
  $async.Future<$0.PerformMigrationResponse> setVersion(
      $grpc.ServiceCall call, $0.SetVersionRequest request);
  $async.Future<$0.PerformMigrationResponse> forceMarkVersion(
      $grpc.ServiceCall call, $0.ForceMarkVersionRequest request);
}
