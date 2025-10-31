import 'dart:convert';
import 'dart:io';

class FileLogger {
  final List<String> _log = [];
  final String? _outputDir;

  FileLogger({String? outputDir}) : _outputDir = outputDir;

  void log(String message) {
    print(message);
    _log.add(message);
  }

  void saveToFile(String filename) {
    final path = _outputDir != null ? '$_outputDir/$filename' : filename;
    File(path).writeAsStringSync(_log.join('\n'));
  }

  void clear() {
    _log.clear();
  }
}

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

  void ensureOutputDir() {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }
}
