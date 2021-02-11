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

typedef Widget ButtonBuilder(BuildContext context, VoidCallback onPressed);

class ConfirmationButton extends StatelessWidget {
  ConfirmationButton(
      {@required this.title,
      @required this.content,
      @required this.buttonBuilder,
      this.onPressed})
      : assert(title != null),
        assert(content != null),
        assert(buttonBuilder != null);

  final Widget title;
  final Widget content;
  final ButtonBuilder buttonBuilder;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return buttonBuilder(
        context,
        onPressed != null
            ? () {
                showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                    title: title,
                    content: content,
                    actions: [
                      TextButton.icon(
                          label: Text("Do Nothing"),
                          icon: Icon(Icons.do_not_disturb),
                          style: Theme.of(context).textButtonTheme.style,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      buttonBuilder(context, () {
                        onPressed();
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                );
              }
            : null);
  }
}
