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
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

class Migration extends Equatable {
  const Migration({
    @required this.version,
    @required this.identifierUp,
    @required this.identifierDown,
    this.sourceUp,
    this.sourceDown,
  })  : assert(version != null),
        assert(identifierUp != null),
        assert(identifierDown != null);

  final int version;
  final String identifierUp;
  final String identifierDown;
  final String sourceUp;
  final String sourceDown;

  static const unloaded =
      Migration(version: -1, identifierUp: "", identifierDown: "");

  String get identifier => identifierUp == identifierDown
      ? identifierUp
      : "$identifierUp / $identifierDown";

  @override
  List<Object> get props =>
      [version, identifierUp, identifierDown, sourceUp, sourceDown];
}
