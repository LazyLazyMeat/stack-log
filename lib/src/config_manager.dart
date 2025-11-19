import 'dart:io';
import 'package:yaml/yaml.dart';

class AppConfig {
  final String inputFile;
  final String outputDir;
  final String runLogSubdir;
  final bool timestampedLogs;
  final int userAgentMaxLength;
  final List<String> filters;
  final String timestampFormat;
  final bool cleanOutput;

  AppConfig({
    required this.inputFile,
    required this.outputDir,
    required this.runLogSubdir,
    required this.timestampedLogs,
    required this.userAgentMaxLength,
    required this.filters,
    required this.timestampFormat,
    required this.cleanOutput,
  });

  factory AppConfig.fromYaml(String yamlContent) {
    final doc = loadYaml(yamlContent);

    return AppConfig(
      inputFile: doc['input']['file'] ?? 'input.json',
      outputDir: doc['output']['directory'] ?? 'output',
      runLogSubdir: doc['output']['run_log_subdirectory'] ?? 'run-logs',
      timestampedLogs: doc['output']['create_timestamped_logs'] ?? true,
      userAgentMaxLength: doc['processing']['user_agent_max_length'] ?? 12,
      timestampFormat:
          doc['processing']['timestamp_format'] ?? 'DD.MM.YY HH:MM:SS:mmm',
      filters: _loadFilters(doc['filters']['file'] ?? 'cfg/filters.txt'),
      cleanOutput: doc['output']['clean_before_run'] ?? false,
    );
  }

  static List<String> _loadFilters(String filterFile) {
    try {
      print('DEBUG: Trying to load filters from: $filterFile');

      final file = File(filterFile);
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        final filters = lines.where((line) => line.trim().isNotEmpty).toList();

        print('DEBUG: Found ${filters.length} filters: $filters');
        return filters;
      } else {
        print('DEBUG: Filter file does not exist: $filterFile');
        print('DEBUG: Current directory: ${Directory.current.path}');
        print('DEBUG: File absolute path: ${file.absolute.path}');
      }
    } catch (e) {
      print('Warning: Could not load filter file: $e');
    }

    print('DEBUG: Using default filters');
    return [
      'Starting new instance',
      'Default STARTUP',
      'Ready condition',
      'audit_log',
    ];
  }
}

class ConfigManager {
  static AppConfig loadConfig(List<String> cliArgs) {
    final cliConfig = _parseCliArgs(cliArgs);

    AppConfig? fileConfig;
    try {
      final configFile = File('cfg/config.yaml');
      if (configFile.existsSync()) {
        fileConfig = AppConfig.fromYaml(configFile.readAsStringSync());
      }
    } catch (e) {
      print('Warning: Could not load config.yaml: $e');
    }

    return _mergeConfigs(cliConfig, fileConfig);
  }

  static AppConfig _parseCliArgs(List<String> args) {
    String? inputFile;
    String? outputDir;
    int? userAgentLength;
    bool cleanOutput = false;

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--input':
        case '-i':
          if (i + 1 < args.length) inputFile = args[++i];
          break;
        case '--output':
        case '-o':
          if (i + 1 < args.length) outputDir = args[++i];
          break;
        case '--user-agent-length':
        case '-l':
          if (i + 1 < args.length) userAgentLength = int.tryParse(args[++i]);
          break;
        case '--clean':
        case '-c':
          cleanOutput = true;
          break;
        case '--help':
        case '-h':
          _printHelp();
          exit(0);
      }
    }

    return AppConfig(
      inputFile: inputFile ?? 'input.json',
      outputDir: outputDir ?? 'output',
      runLogSubdir: 'run-logs',
      timestampedLogs: true,
      userAgentMaxLength: userAgentLength ?? 12,
      filters: [],
      timestampFormat: 'DD.MM.YY HH:MM:SS:mmm',
      cleanOutput: cleanOutput,
    );
  }

  static AppConfig _mergeConfigs(AppConfig cliConfig, AppConfig? fileConfig) {
    if (fileConfig == null) return cliConfig;

    return AppConfig(
      inputFile: cliConfig.inputFile != 'input.json'
          ? cliConfig.inputFile
          : fileConfig.inputFile,
      outputDir: cliConfig.outputDir != 'output'
          ? cliConfig.outputDir
          : fileConfig.outputDir,
      runLogSubdir: fileConfig.runLogSubdir,
      timestampedLogs: fileConfig.timestampedLogs,
      userAgentMaxLength: cliConfig.userAgentMaxLength != 12
          ? cliConfig.userAgentMaxLength
          : fileConfig.userAgentMaxLength,
      filters: fileConfig.filters,
      timestampFormat: fileConfig.timestampFormat,
      cleanOutput: cliConfig.cleanOutput ? true : fileConfig.cleanOutput,
    );
  }

  static void _printHelp() {
    print('''
Google Cloud Log Parser

Usage:
  dart parser.dart [OPTIONS] [INPUT_FILE]

Arguments:
  input_file              Input JSON file (default: input.json)

Options:
  -i, --input <file>      Input JSON file
  -o, --output <dir>      Output directory (default: output)
  -l, --user-agent-length <num>  User agent max length (default: 12)
  -c, --clean             Clean output directory before processing
  -h, --help              Show this help message

Examples:
  dart parser.dart
  dart parser.dart logs.json
  dart parser.dart --input logs.json --output results --clean
  dart parser.dart --user-agent-length 15 --clean
''');
  }
}
