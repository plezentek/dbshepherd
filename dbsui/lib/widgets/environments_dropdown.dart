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

// Project imports:
import 'package:dbsui/string_extensions.dart';

class EnvironmentsDropdown extends StatelessWidget {
  EnvironmentsDropdown(
      {this.selectedEnvironment,
      this.defaultEnvironment,
      this.environments,
      this.onChanged});

  final String selectedEnvironment;
  final String defaultEnvironment;
  final List<String> environments;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text("Environments:"),
      ),
      DropdownButton<String>(
        value: selectedEnvironment ??
            defaultEnvironment ??
            environments?.first ??
            "",
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        onChanged: onChanged,
        selectedItemBuilder: (context) {
          return environments.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == defaultEnvironment
                    ? "${value.toCapitalized()} (Default)"
                    : value.toCapitalized(),
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              ),
            );
          }).toList();
        },
        items: environments.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value == defaultEnvironment
                  ? "${value.toCapitalized()} (Default)"
                  : value.toCapitalized(),
            ),
          );
        }).toList(),
      )
    ]);
  }
}
