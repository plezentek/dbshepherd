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

import 'package:formz/formz.dart';

enum DataVersionValidationError { invalid }

class DataVersion extends FormzInput<int, DataVersionValidationError> {
  const DataVersion.pure() : super.pure(-1);
  const DataVersion.dirty([int value = -1]) : super.dirty(value);

  @override
  DataVersionValidationError validator(int value) {
    return value > 0 ? null : DataVersionValidationError.invalid;
  }
}
