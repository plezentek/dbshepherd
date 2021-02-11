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

// Package imports:
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/foundation.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class LazySourceView extends StatefulWidget {
  LazySourceView({this.source, this.onMissing});

  final String source;
  final VoidCallback onMissing;

  @override
  LazySourceViewState createState() => LazySourceViewState();
}

class LazySourceViewState extends State<LazySourceView> {
  @override
  void initState() {
    super.initState();
    if (widget.source == null) {
      widget.onMissing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.source == null
        ? Shimmer(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Container(height: 16, color: Colors.grey[300]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Container(height: 16, color: Colors.grey[300]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 80),
                    child: Container(height: 16, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          )
        : Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: HighlightView(
                    widget.source,
                    language: 'sql',
                    theme: foundationTheme,
                    padding: EdgeInsets.all(12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          );
  }
}
