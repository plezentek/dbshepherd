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

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

// Project imports:

class OperationButton extends StatelessWidget {
  OperationButton(
      {@required this.submitting,
      @required this.allowDowngrade,
      @required this.version,
      @required this.allowForcedVersion,
      @required this.opIsForcedVersion,
      @required this.opVersion,
      @required this.dbVersion,
      this.onPressed})
      : assert(submitting != null),
        assert(allowDowngrade != null),
        assert(version != null),
        assert(allowForcedVersion != null),
        assert(opIsForcedVersion != null),
        assert(opVersion != null),
        assert(dbVersion != null);

  final bool submitting;
  final bool allowDowngrade;
  final int version;
  final bool allowForcedVersion;
  final bool opIsForcedVersion;
  final int opVersion;
  final int dbVersion;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: !submitting &&
              (allowForcedVersion ||
                  ((version != dbVersion) &&
                      (allowDowngrade || version > dbVersion)))
          ? onPressed
          : null,
      icon: (submitting &&
              version == opVersion &&
              (allowForcedVersion == opIsForcedVersion))
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ))
          : allowForcedVersion
              ? Icon(Icons.warning_rounded)
              : allowDowngrade && version < dbVersion
                  ? Icon(Icons.download_rounded)
                  : version > dbVersion
                      ? Icon(Icons.upload_rounded)
                      : Icon(Icons.check),
      label: Text(
        (submitting &&
                version == opVersion &&
                (allowForcedVersion == opIsForcedVersion))
            ? "In progress"
            : allowForcedVersion
                ? "Force Version"
                : allowDowngrade && version < dbVersion
                    ? "Downgrade"
                    : version > dbVersion
                        ? "Upgrade"
                        : "Applied",
      ),
    );
  }
}
