#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:google_cloud_log_parser/google_cloud_log_parser.dart';
import 'package:google_cloud_log_parser/src/config.dart';

void main(List<String> arguments) {
  final config = ParserConfig.fromArgs(arguments);

  // Проверяем входной файл
  final inputFile = File(config.inputFile);
  if (!inputFile.existsSync()) {
    print('Ошибка: входной файл не найден: ${config.inputFile}');
    print('Используйте --help для справки');
    exit(1);
  }

  // Создаем выходную директорию
  config.ensureOutputDir();

  final logger = FileLogger(outputDir: config.outputDir);
  final outputWriter = OutputWriter(config.outputDir);

  logger.log('Google Cloud Log Parser');
  logger.log('=======================');
  logger.log('Входной файл: ${config.inputFile}');
  logger.log('Выходная директория: ${config.outputDir}');
  logger.log('');

  try {
    final jsonString = inputFile.readAsStringSync();
    final List<dynamic> data = json.decode(jsonString);

    final List<String> textResults = [];
    final List<Map<String, dynamic>> jsonResults = [];
    final List<Map<String, dynamic>> jsonPayloadResults = [];
    final List<String> errors = [];

    logger.log('Начата обработка ${data.length} записей...');

    for (int i = 0; i < data.length; i++) {
      try {
        final item = data[i];
        if (item is! Map) {
          throw FormatException('Элемент не является объектом JSON');
        }

        final severity = item['severity']?.toString();
        final timestamp = formatTimestamp(item['timestamp']?.toString());
        final userAgent = item['httpRequest']?['userAgent']?.toString();

        final textPayload = item['textPayload']?.toString();
        final jsonPayload = item['jsonPayload'];
        final dynamic payload = jsonPayload ?? textPayload;

        String? payloadString;
        if (payload is String) {
          payloadString = payload;
        } else if (payload != null) {
          payloadString = json.encode(payload);
        }

        if (shouldFilterPayload(payloadString, defaultFilters)) {
          continue;
        }

        final textParts = <String>[];
        if (timestamp != null) textParts.add('($timestamp)');
        if (severity != null) textParts.add('[$severity]');
        if (userAgent != null)
          textParts.add('<${shortenUserAgent(userAgent)}>');
        if (payloadString != null) textParts.add(payloadString);

        if (textParts.isNotEmpty) {
          textResults.add(textParts.join(' '));
        }

        final Map<String, dynamic> jsonObject = {};
        if (severity != null) jsonObject['Severity'] = severity;
        if (userAgent != null) jsonObject['Agent'] = userAgent;
        if (timestamp != null) jsonObject['Time'] = timestamp;
        if (payloadString != null) jsonObject['log'] = payloadString;

        if (jsonObject.isNotEmpty) {
          jsonResults.add(jsonObject);

          if (payload != null) {
            dynamic parsedPayload;

            if (payload is String) {
              if (isJsonLike(payload)) {
                parsedPayload = tryParseJson(payload);
              }
            } else {
              parsedPayload = payload;
            }

            if (parsedPayload != null) {
              final Map<String, dynamic> jsonPayloadObject = {};
              if (severity != null) jsonPayloadObject['Severity'] = severity;
              if (userAgent != null) jsonPayloadObject['Agent'] = userAgent;
              if (timestamp != null) jsonPayloadObject['Time'] = timestamp;
              jsonPayloadObject['log'] = parsedPayload;

              jsonPayloadResults.add(jsonPayloadObject);
            }
          }
        }
      } catch (e, stackTrace) {
        final errorMessage = '''
Ошибка обработки элемента с индексом $i:
Тип ошибки: ${e.runtimeType}
Сообщение: $e
Элемент: ${data[i]}
Stack trace: $stackTrace
------------------------
''';
        errors.add(errorMessage);
        logger.log('Ошибка в элементе $i: $e');
      }
    }

    // Сохраняем результаты в выходную директорию
    if (textResults.isNotEmpty) {
      outputWriter.writeTextFile('output.txt', textResults.join('\n'));
      logger.log(
          '✓ Текстовый результат сохранен в ${config.getOutputPath('output.txt')}');
    } else {
      logger.log('✗ Нет данных для сохранения в текстовом формате.');
    }

    if (jsonResults.isNotEmpty) {
      outputWriter.writeJsonFile('output.json', jsonResults);
      logger.log(
          '✓ JSON результат сохранен в ${config.getOutputPath('output.json')}');
    } else {
      logger.log('✗ Нет данных для сохранения в JSON формате.');
    }

    if (jsonPayloadResults.isNotEmpty) {
      outputWriter.writeJsonFile('json_payloads.json', jsonPayloadResults);
      logger.log(
          '✓ Логи с JSON-подобным payload сохранены в ${config.getOutputPath('json_payloads.json')}');
      logger.log(
          '  Найдено ${jsonPayloadResults.length} логов с JSON-подобным payload.');
    } else {
      logger.log('✗ Логов с JSON-подобным payload не обнаружено.');
    }

    if (errors.isNotEmpty) {
      outputWriter.writeTextFile('errors.txt', errors.join('\n'));
      logger.log(
          '⚠ Найдено ${errors.length} ошибок. Подробности в ${config.getOutputPath('errors.txt')}');
    } else {
      logger.log('✓ Ошибок не обнаружено.');
    }

    logger.log('');
    logger.log('Обработка завершена!');
    logger.log(
        '✓ Успешно обработано: ${textResults.length} из ${data.length} элементов');
    logger.log(
        '✓ Отфильтровано: ${data.length - textResults.length - errors.length} элементов');

    if (errors.isNotEmpty) {
      logger.log('⚠ С ошибками: ${errors.length} элементов');
    }

    logger.saveToFile('run-log.txt');
    logger.log(
        '✓ Лог выполнения сохранен в ${config.getOutputPath('run-log.txt')}');

    // Предлагаем использовать highlighter для просмотра результатов
    if (textResults.isNotEmpty) {
      logger.log('');
      logger.log('Для красивого просмотра результатов выполните:');
      logger
          .log('  dart highlighter.dart ${config.getOutputPath('output.txt')}');
      logger.log('или после компиляции:');
      logger.log(
          '  gcloud_log_highlighter ${config.getOutputPath('output.txt')}');
    }
  } catch (e) {
    final errorMessage = 'Критическая ошибка: $e';
    logger.log(errorMessage);
    logger.saveToFile('run-log.txt');
    logger.log(
        'Лог выполнения сохранен в ${config.getOutputPath('run-log.txt')}');
    exit(1);
  }
}
