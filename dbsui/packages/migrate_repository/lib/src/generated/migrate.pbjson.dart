///
//  Generated code. Do not modify.
//  source: migrate.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

const Empty$json = const {
  '1': 'Empty',
};

const Environment$json = const {
  '1': 'Environment',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

const ListEnvironmentsResponse$json = const {
  '1': 'ListEnvironmentsResponse',
  '2': const [
    const {'1': 'environments', '3': 1, '4': 3, '5': 11, '6': '.open.Environment', '10': 'environments'},
  ],
};

const GetDatabaseVersionResponse$json = const {
  '1': 'GetDatabaseVersionResponse',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 4, '10': 'version'},
    const {'1': 'is_dirty', '3': 2, '4': 1, '5': 8, '10': 'isDirty'},
    const {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

const Migration$json = const {
  '1': 'Migration',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 4, '10': 'version'},
    const {'1': 'identifier_up', '3': 2, '4': 1, '5': 9, '10': 'identifierUp'},
    const {'1': 'identifier_down', '3': 3, '4': 1, '5': 9, '10': 'identifierDown'},
    const {'1': 'source_up', '3': 4, '4': 1, '5': 9, '10': 'sourceUp'},
    const {'1': 'source_down', '3': 5, '4': 1, '5': 9, '10': 'sourceDown'},
  ],
};

const ListMigrationsResponse$json = const {
  '1': 'ListMigrationsResponse',
  '2': const [
    const {'1': 'migrations', '3': 1, '4': 3, '5': 11, '6': '.open.Migration', '10': 'migrations'},
  ],
};

const GetMigrationRequest$json = const {
  '1': 'GetMigrationRequest',
  '2': const [
    const {'1': 'environment', '3': 1, '4': 1, '5': 9, '10': 'environment'},
    const {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
  ],
};

const GetMigrationResponse$json = const {
  '1': 'GetMigrationResponse',
  '2': const [
    const {'1': 'migration', '3': 1, '4': 1, '5': 11, '6': '.open.Migration', '10': 'migration'},
  ],
};

const SetVersionRequest$json = const {
  '1': 'SetVersionRequest',
  '2': const [
    const {'1': 'environment', '3': 1, '4': 1, '5': 9, '10': 'environment'},
    const {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
  ],
};

const PerformMigrationResponse$json = const {
  '1': 'PerformMigrationResponse',
  '2': const [
    const {'1': 'successful', '3': 1, '4': 1, '5': 8, '10': 'successful'},
    const {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
  ],
};

const ForceMarkVersionRequest$json = const {
  '1': 'ForceMarkVersionRequest',
  '2': const [
    const {'1': 'environment', '3': 1, '4': 1, '5': 9, '10': 'environment'},
    const {'1': 'version', '3': 2, '4': 1, '5': 4, '10': 'version'},
  ],
};

