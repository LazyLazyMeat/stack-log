#!/usr/bin/env dart
/*
 * parser.dart - A command-line tool for parsing logs and extracting tokens.
 *
 * Copyright (C) 2025 Uvarov Oleg <uv.ol.al@gmail.com>
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

import 'dart:convert';
import 'dart:io';

import 'package:stack_log/src/config_manager.dart';
import 'package:stack_log/src/output_writer.dart';
import 'package:stack_log/src/formatters.dart';
import 'package:stack_log/src/logger.dart';

void main(List<String> arguments) {
  final config = ConfigManager.loadConfig(arguments);
  final logger = RunLogger(
    config.outputDir,
    config.runLogSubdir,
    timestamped: config.timestampedLogs,
  );

  try {
    _runParser(config, logger);
  } catch (e, stackTrace) {
    logger.log('CRITICAL ERROR: $e');
    logger.log('Stack trace: $stackTrace');
    exit(1);
  } finally {
    logger.save();
  }
}

void _runParser(AppConfig config, RunLogger logger) {
  logger.log('Google Cloud Log Parser');
  logger.log('=======================');
  logger.log('Configuration:');
  logger.log('  Input file: ${config.inputFile}');
  logger.log('  Output directory: ${config.outputDir}');
  logger.log('  User agent max length: ${config.userAgentMaxLength}');
  logger.log('  Active filters: ${config.filters.length}');
  logger.log('  Timestamped logs: ${config.timestampedLogs}');
  logger.log('');

  if (config.cleanOutput) {
    _cleanOutputDirectory(config.outputDir, logger);
  }

  final inputFile = File(config.inputFile);
  if (!inputFile.existsSync()) {
    logger.log('ERROR: Input file not found: ${config.inputFile}');
    logger.log('Please check the file path or use --input parameter');
    return;
  }

  logger.log('Reading input file: ${config.inputFile}');
  final jsonString = inputFile.readAsStringSync();
  final List<dynamic> data = json.decode(jsonString);
  logger.log('Found ${data.length} log entries to process');
  logger.log('');

  final outputDir = Directory(config.outputDir);
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    logger.log('Created output directory: ${config.outputDir}');
  }

  final List<String> textResults = [];
  final List<Map<String, dynamic>> jsonResults = [];
  final List<Map<String, dynamic>> jsonPayloadResults = [];
  final List<String> errors = [];

  int processedCount = 0;
  int filteredCount = 0;
  int errorCount = 0;

  for (int i = 0; i < data.length; i++) {
    try {
      final item = data[i];
      if (item is! Map) {
        throw FormatException('Element is not a JSON object');
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

      bool shouldFilter = false;
      if (payloadString != null) {
        for (final filter in config.filters) {
          if (payloadString.startsWith(filter)) {
            shouldFilter = true;
            filteredCount++;
            break;
          }
        }
      }

      if (shouldFilter) {
        continue;
      }

      final textParts = <String>[];
      if (timestamp != null) textParts.add('($timestamp)');
      if (severity != null) textParts.add('||$severity||');
      if (userAgent != null) {
        final shortenedAgent =
            _shortenUserAgent(userAgent, config.userAgentMaxLength);
        textParts.add('<$shortenedAgent>');
      }
      if (payloadString != null) textParts.add(payloadString);

      if (textParts.isNotEmpty) {
        textResults.add(textParts.join(' '));
      }

      final Map<String, dynamic> jsonObject = {};
      if (severity != null) jsonObject['severity'] = severity;
      if (userAgent != null) jsonObject['agent'] = userAgent;
      if (timestamp != null) jsonObject['time'] = timestamp;
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

          if (parsedPayload != null && parsedPayload is! String) {
            final Map<String, dynamic> jsonPayloadObject = {};
            if (severity != null) jsonPayloadObject['severity'] = severity;
            if (userAgent != null) jsonPayloadObject['agent'] = userAgent;
            if (timestamp != null) jsonPayloadObject['time'] = timestamp;
            jsonPayloadObject['log'] = parsedPayload;

            jsonPayloadResults.add(jsonPayloadObject);
          }
        }
      }

      processedCount++;

      if (processedCount % 100 == 0) {
        logger.log('Processed $processedCount/${data.length} entries...');
      }
    } catch (e, stackTrace) {
      errorCount++;
      final errorMessage = '''
Error processing element at index $i:
Error type: ${e.runtimeType}
Message: $e
Element: ${data[i]}
Stack trace: $stackTrace
------------------------
''';
      errors.add(errorMessage);
      logger.log('ERROR at element $i: $e');
    }
  }

  logger.log('');
  logger.log('Processing completed:');
  logger.log('  Total entries: ${data.length}');
  logger.log('  Successfully processed: $processedCount');
  logger.log('  Filtered out: $filteredCount');
  logger.log('  Errors: $errorCount');
  logger.log('');

  final outputWriter = OutputWriter(config.outputDir);

  if (textResults.isNotEmpty) {
    outputWriter.writeTextFile('output.txt', textResults.join('\n'));
    logger.log('✓ Text output saved to ${config.outputDir}/output.txt');
    logger.log('  Lines written: ${textResults.length}');
  } else {
    logger.log('✗ No data available for text output');
  }

  if (jsonResults.isNotEmpty) {
    outputWriter.writeJsonFile('output.json', jsonResults);
    logger.log('✓ JSON output saved to ${config.outputDir}/output.json');
    logger.log('  Objects written: ${jsonResults.length}');
  } else {
    logger.log('✗ No data available for JSON output');
  }

  if (jsonPayloadResults.isNotEmpty) {
    outputWriter.writeJsonFile('json_payloads.json', jsonPayloadResults);
    logger
        .log('✓ JSON payloads saved to ${config.outputDir}/json_payloads.json');
    logger.log('  JSON objects parsed: ${jsonPayloadResults.length}');
  } else {
    logger.log('✗ No JSON payloads found');
  }

  if (errors.isNotEmpty) {
    outputWriter.writeTextFile('errors.txt', errors.join('\n'));
    logger.log('⚠ Errors saved to ${config.outputDir}/errors.txt');
    logger.log('  Error count: ${errors.length}');
  } else {
    logger.log('✓ No errors encountered');
  }

  logger.log('');
  logger.log('=== PROCESSING SUMMARY ===');
  logger.log('Input: ${config.inputFile}');
  logger.log('Output directory: ${config.outputDir}');
  logger.log('Total entries: ${data.length}');
  logger.log(
      'Successfully processed: $processedCount (${_calculatePercentage(processedCount, data.length)}%)');
  logger.log(
      'Filtered out: $filteredCount (${_calculatePercentage(filteredCount, data.length)}%)');
  logger.log(
      'Errors: $errorCount (${_calculatePercentage(errorCount, data.length)}%)');
  logger.log(
      'Efficiency: ${_calculatePercentage(processedCount + filteredCount, data.length)}%');

  if (textResults.isNotEmpty) {
    logger.log('');
    logger.log('Next steps:');
    logger.log('  View formatted results: dart run bin/highlighter.dart');
    logger.log(
        '  Or: dart run bin/highlighter.dart ${config.outputDir}/output.txt');
  }

  if (errors.isNotEmpty) {
    logger.log('');
    logger.log('⚠ Review errors in: ${config.outputDir}/errors.txt');
  }
}

void _cleanOutputDirectory(String outputDir, RunLogger logger) {
  final directory = Directory(outputDir);
  if (directory.existsSync()) {
    try {
      logger.log('Cleaning output directory: $outputDir');

      directory.deleteSync(recursive: true);
      logger.log('✓ Output directory cleaned successfully');

      directory.createSync(recursive: true);
      logger.log('✓ Output directory recreated');
    } catch (e) {
      logger.log('⚠ Warning: Could not clean output directory: $e');
      logger.log('  Continuing with existing directory...');
    }
  } else {
    logger.log('Output directory does not exist, no cleaning needed');
  }
}

String _shortenUserAgent(String userAgent, int maxLength) {
  if (userAgent.length <= maxLength) {
    return userAgent;
  }
  return '${userAgent.substring(0, maxLength)}...';
}

String _calculatePercentage(int part, int total) {
  if (total == 0) return '0';
  return ((part / total) * 100).toStringAsFixed(1);
}
