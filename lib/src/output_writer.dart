// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2025 Uvarov Oleg <uv.ol.al@gmail.com>

import 'dart:convert';
import 'dart:io';

class OutputWriter {
  final String outputDir;

  OutputWriter(this.outputDir);

  void writeTextFile(String filename, String content) {
    File('$outputDir/$filename').writeAsStringSync(content);
  }

  void writeJsonFile(String filename, dynamic jsonData) {
    final encoder = JsonEncoder.withIndent('  ');
    final jsonOutput = encoder.convert(jsonData);
    writeTextFile(filename, jsonOutput);
  }
}
