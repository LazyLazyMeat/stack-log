import 'dart:io';

class RunLogger {
  final List<String> _buffer = [];
  final String _logFilePath;

  RunLogger(
    String outputDir,
    String runLogSubdir, {
    bool timestamped = true,
  }) : _logFilePath = _generateLogPath(
          outputDir,
          runLogSubdir,
          timestamped,
        ) {
    _ensureDirectoryExists();
  }

  static String _generateLogPath(
    String outputDir,
    String runLogSubdir,
    bool timestamped,
  ) {
    final logsDir = '$outputDir/$runLogSubdir';
    if (!timestamped) return '$logsDir/run.log';

    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_'
        '${_twoDigits(now.hour)}-${_twoDigits(now.minute)}-${_twoDigits(now.second)}';
    return '$logsDir/${timestamp}_run.log';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _ensureDirectoryExists() {
    try {
      final file = File(_logFilePath);
      final directory = file.parent;
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    } catch (error) {
      print('Warning: Could not create log directory: $error');
    }
  }

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';

    print(message); // Console output
    _buffer.add(logMessage); // File output
  }

  void save() {
    if (_buffer.isEmpty) return;

    try {
      _ensureDirectoryExists();
      File(_logFilePath).writeAsStringSync(_buffer.join('\n'));
      print('Execution log saved to: $_logFilePath');
    } catch (e) {
      print('Warning: Could not save run log: $e');
    }
  }

  String get logFilePath => _logFilePath;
}
