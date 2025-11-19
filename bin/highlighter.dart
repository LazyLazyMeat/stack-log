#!/usr/bin/env dart
/*
 * highlighter.dart - A command-line tool for highlighting parsed logs.
 *
 * Copyright (C) 2024 Uvarov Oleg <uv.ol.al@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:stack_log/src/console_colors.dart';
import 'package:stack_log/src/log_highlighter.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  final highlightConfig = _loadHighlightConfig();

  String filePath;
  if (arguments.isEmpty) {
    filePath = 'output/output.txt';

    final defaultFile = File(filePath);
    if (!defaultFile.existsSync()) {
      print('Файл по умолчанию не найден: $filePath');
      print('');
      _printHelp();
      return;
    }
  } else if (arguments.contains('--help')) {
    _printHelp();
    return;
  } else {
    filePath = arguments.first;
  }

  try {
    final highlighter = LogHighlighter(
      severityColor: highlightConfig['severity_color']!,
      timestampColor: highlightConfig['timestamp_color']!,
      userAgentColor: highlightConfig['user_agent_color']!,
    );

    highlighter.highlightFile(filePath);
  } catch (e) {
    print('Ошибка: $e');
    print('');
    print('Убедитесь, что:');
    print('  1. Файл существует: $filePath');
    print('  2. У вас есть права на чтение файла');
    print('  3. Файл содержит логи в правильном формате');
    exit(1);
  }
}

Map<String, ConsoleColors> _loadHighlightConfig() {
  try {
    final configFile = File('cfg/config.yaml');
    if (configFile.existsSync()) {
      final yamlContent = configFile.readAsStringSync();
      final doc = loadYaml(yamlContent);

      final highlighting = doc['highlighting'] as Map<dynamic, dynamic>?;
      if (highlighting != null) {
        return {
          'severity_color': ConsoleColors.fromName(
              highlighting['severity_color']?.toString() ?? 'blue'),
          'timestamp_color': ConsoleColors.fromName(
              highlighting['timestamp_color']?.toString() ?? 'green'),
          'user_agent_color': ConsoleColors.fromName(
              highlighting['user_agent_color']?.toString() ?? 'red'),
        };
      }
    }
  } catch (e) {
    print(
        'Предупреждение: не удалось загрузить настройки цветов из config.yaml: $e');
  }

  return {
    'severity_color': ConsoleColors.blue,
    'timestamp_color': ConsoleColors.green,
    'user_agent_color': ConsoleColors.red,
  };
}

void _printHelp() {
  print('''
Google Cloud Log Highlighter

Использование:
  dart highlighter.dart [file_path]

Позиционные аргументы:
  file_path               Файл для подсветки (по умолчанию: output/output.txt)

Опции:
  --help                  Показать эту справку

Примеры:
  dart highlighter.dart                          # Подсветит output/output.txt
  dart highlighter.dart my_logs.txt              # Подсветит указанный файл
  dart highlighter.dart --help

Примечание:
  По умолчанию ищет файл output/output.txt в текущей рабочей директории.
  Убедитесь, что вы запускаете парсер перед использованием highlighter.
''');
}
