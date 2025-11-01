// lib/some_helper.dart
// GPL-3.0 License - See LICENSE file for details

library google_cloud_log_parser.src.config;

import 'dart:io';

class ParserConfig {
  final String inputFile;
  final String outputDir;
  final bool createOutputDir;

  ParserConfig({
    required this.inputFile,
    this.outputDir = 'output',
    this.createOutputDir = true,
  });

  /// Создает конфигурацию из аргументов командной строки
  factory ParserConfig.fromArgs(List<String> args) {
    String inputFile = 'input.json';
    String outputDir = 'output';

    for (int i = 0; i < args.length; i++) {
      if (args[i] == '--input' && i + 1 < args.length) {
        inputFile = args[i + 1];
      } else if (args[i] == '--output' && i + 1 < args.length) {
        outputDir = args[i + 1];
      } else if (args[i] == '--help') {
        _printHelp();
        exit(0);
      } else if (!args[i].startsWith('--') && inputFile == 'input.json') {
        // Позиционный аргумент для обратной совместимости
        inputFile = args[i];
      }
    }

    return ParserConfig(inputFile: inputFile, outputDir: outputDir);
  }

  static void _printHelp() {
    print('''
Google Cloud Log Parser

Использование:
  dart parser.dart [ОПЦИИ] [input_file]

Позиционные аргументы:
  input_file              Входной JSON файл (по умолчанию: input.json)

Опции:
  --input <file>          Входной JSON файл
  --output <dir>          Выходная директория (по умолчанию: output)
  --help                  Показать эту справку

Примеры:
  dart parser.dart logs.json
  dart parser.dart --input logs.json --output results
  dart parser.dart --help
''');
  }

  /// Создает выходную директорию если нужно
  void ensureOutputDir() {
    if (createOutputDir) {
      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }
  }

  /// Получает полный путь к файлу в выходной директории
  String getOutputPath(String filename) {
    return '$outputDir/$filename';
  }
}
