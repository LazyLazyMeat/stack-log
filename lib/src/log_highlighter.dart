// lib/some_helper.dart
// GPL-3.0 License - See LICENSE file for details

import 'dart:io';

import 'console_colors.dart';

class LogHighlighter {
  final ConsoleColors severityColor;
  final ConsoleColors timestampColor;
  final ConsoleColors userAgentColor;

  LogHighlighter({
    this.severityColor = ConsoleColors.blue,
    this.timestampColor = ConsoleColors.green,
    this.userAgentColor = ConsoleColors.red,
  });

  String highlightLine(String line) {
    return line.replaceAllMapped(
      RegExp(r'\|\|(.*?)\|\||\((.*?)\)|<(.*?)>'),
      (match) {
        if (match.group(1) != null) {
          return '$severityColor${match.group(1)}${ConsoleColors.reset}';
        } else if (match.group(2) != null) {
          return '$timestampColor${match.group(2)}${ConsoleColors.reset}';
        } else {
          return '$userAgentColor${match.group(3)}${ConsoleColors.reset}';
        }
      },
    );
  }

  void highlightFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Файл не найден: $filePath');
    }

    final lines = file.readAsLinesSync();

    if (lines.isEmpty) {
      print('Файл пуст: $filePath');
      return;
    }

    print('Подсветка файла: $filePath');
    print('=' * 50);

    for (final line in lines) {
      print(highlightLine(line));
    }

    print('=' * 50);
    print('Обработано строк: ${lines.length}');
  }
}
