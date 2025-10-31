library google_cloud_log_parser.src.color_output;

import 'dart:io';

class ConsoleColors {
  static const String reset = '\x1B[0m';
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  static const String bold = '\x1B[1m';
  static const String underline = '\x1B[4m';
}

class LogHighlighter {
  static String highlightLine(String line) {
    return line.replaceAllMapped(
      RegExp(r'\[(.*?)\]|\((.*?)\)|<(.*?)>'),
      (match) {
        if (match.group(1) != null) {
          // Содержимое квадратных скобок - синий (severity)
          return '${ConsoleColors.blue}${match.group(1)}${ConsoleColors.reset}';
        } else if (match.group(2) != null) {
          // Содержимое круглых скобок - зеленый (timestamp)
          return '${ConsoleColors.green}${match.group(2)}${ConsoleColors.reset}';
        } else {
          // Содержимое угловых скобок - красный (userAgent)
          return '${ConsoleColors.red}${match.group(3)}${ConsoleColors.reset}';
        }
      },
    );
  }

  static void highlightFile(String filePath) {
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
