# StackLog

![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey)](https://pub.dev/packages/stack_log)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Null Safety](https://img.shields.io/badge/Null%20Safety-✓-success)
![Dart Analysis](https://img.shields.io/badge/Analysis-Passing-brightgreen)

## Table of Contents
- [🚀 Features](#features)
- [📦 Installation](#installation)
- [⚡ Quick Start](#quick-start)
- [📁 Input Format](#input-format)
- [🛠️ Usage](#usage)
- [📊 Output](#outputs)
- [🏗️ Building from Source](#building-from-source)
- [👨‍💻 Author](#author)
- [📜 License](#license)
- [🚧 TODO](#todo)


<a name="features"></a>
## 🚀 Features

* 📊 Google Cloud Log Processing: Parse and analyze structured JSON logs from Google Cloud Platform (GCP)
* 🎨 Syntax Highlighting: Beautiful color-coded output for enhanced log readability
* 🔄 Dual Payload Support: Handles both textPayload and jsonPayload fields with intelligent preference
* 📁 Organized Output: Automatically creates structured output directory with categorized files


<a name="installation"></a>
## 📦 Installation
### Prerequisites
* Dart SDK 3.0+ - Required to run or compile the project

### Method 1: From Source (Recommended for Development)
Clone the repository:
```
git clone https://github.com/LazyLazyMeat/stack-log.git
cd stack-log
```
Install dependencies:
```
dart pub get
```
Verify installation:
```
dart run bin/parser.dart --help
```

### Method 2: Using Pre-compiled Binaries
```
Will be added soon
```

### Method 3: Global Installation (After Building)
```
Will be added soon
```

### Verifying Installation
Test that everything is working correctly:
```
dart run bin/parser.dart --help
dart run bin/highlighter.dart --help
```

Or with compiled versions
```
Will be added later
```

### Platform-Specific Notes
```
Windows:
```
* Use Command Prompt or PowerShell
* Ensure Dart SDK is in your PATH
* Build produces .exe files
```
Linux:
```
* Works with most common distributions
* Build produces executable binaries
* May need to set execute permissions: `chmod +x build/*`


<a name="quick-start"></a>
## ⚡ Quick Start
### Step 1: Prepare raw log file
You can find valid example of `input.json` in `example/input.json`

### Step 2: Run the Parser
* Basic usage (uses input.json in current directory): `dart run bin/parser.dart`
* Or specify your log file: `dart run bin/parser.dart my_logs.json`
* With custom output directory: `dart run bin/parser.dart --input my_logs.json --output my_results`

### Step 3: View the Results
* View the default output (output/output.txt): `dart run bin/highlighter.dart`
* Or specify a file: `dart run bin/highlighter.dart output/output.txt`

Expected Output:
* You should see color-coded logs like this:
```
(05.10.23 12:00:00:123) [INFO] <Mozilla/5.0...> User logged in successfully
(05.10.23 12:01:30:456) [ERROR] Database connection failed
```

### Step 4: Explore Generated Files
Check the `output/` directory for all processed data:
```
ls output/
# output.txt            - Formatted logs (used by highlighter)
# output.json           - Structured JSON data
# json_payloads.json    - Parsed JSON payloads
# errors.txt            - Any processing errors
# run-log.txt           - Execution log
```

<a name="input-format"></a>
## 📁 Input Format
The parser expects logs in the standard Google Cloud Logging JSON format. The input file must be a JSON array containing log entry objects.

### Basic Structure
```
[
  {
    // Log entry 1
  },
  {
    // Log entry 2
  }
]
```

### Supported Fields
| Field                   | Type   | Required | Description                                   |
|-------------------------|--------|----------|-----------------------------------------------|
| `severity`              | string | ❌        | Log level (DEBUG, INFO, WARNING, ERROR, etc.) |
| `timestamp`             | string | ❌        | ISO 8601                                      |
| `textPayload`           | string | ⚠️       | Plain text log message                        |
| `jsonPayload`           | object | ⚠️       | Structured JSON log data                      |
| `httpRequest.userAgent` | string | ❌        | HTTP user agent string                        |

**Legend:** ❌ Optional, ⚠️ At least one payload required

### Complete example
Minimal valid entry:
```json
[
  {
    "severity": "INFO",
    "timestamp": "2025-11-01T12:00:00.000Z",
    "httpRequest": {
      "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    },
    "textPayload": "User session created for user@example.com"
  },
  {
    "severity": "ERROR",
    "timestamp": "2025-11-01T12:01:00.000Z",
    "jsonPayload": {
      "message": "Database connection timeout",
      "errorCode": "DB_CONN_001"
    }
  }
]
```

### Field Priority
If both `textPayload` and `jsonPayload` are present, `jsonPayload` takes precedence. Missing fields are not included in output, invalid fields are ignored.

### Filtered Messages
The following log messages are automatically filtered out and won't appear in output files:
* Messages starting with "Starting new instance"
* Messages starting with "Default STARTUP"
* Messages starting with "Ready condition"
* Messages starting with "audit_log"


### Validation
The parser will:
* ✅ Process valid log entries
* ⚠️ Skip entries with missing required structure (with error messages)
* ❌ Stop processing if the root is not a JSON array


<a name="usage"></a>
## 🛠️ Usage
### Parser
The main parser processes Google Cloud log files and generates multiple output formats.

#### Basic Syntax
```bash
dart run bin/parser.dart [OPTIONS] [INPUT_FILE]
```

#### Arguments
| Argument   | Description         | Default      |
|------------|---------------------|--------------|
| `--input`  | Input JSON log file | `input.json` |
| `--output` | Output directory    | `output`     |
| `--help`   | Show help message   | -            |

#### Examples
Basic Usage:

```bash
# Process default input.json, create output/ directory
dart run bin/parser.dart

# Process specific file
dart run bin/parser.dart my_logs.json

# Using positional argument (legacy style)
dart run bin/parser.dart logs/application.json
```
Advanced Usage:

```bash
# Custom input and output paths
dart run bin/parser.dart --input logs/production.json --output analysis/results

# Using short options
dart run bin/parser.dart -i cloud_logs.json -o processed_logs

# Show help
dart run bin/parser.dart --help
```

With Compiled Binary:
```
Will be added soon
```

#### Output Files
After processing, the following files are created in the output directory:
* `output.txt` - Formatted text logs (human readable)
* `output.json` - Structured JSON data
* `json_payloads.json` - Parsed JSON payloads
* `errors.txt` - Processing errors with details
* `run-log.txt` - Execution log and statistics

### Highlighter

#### Basic Syntax
```bash
dart run bin/highlighter.dart [FILE_PATH]
```

#### Arguments
| Argument    | Description       | Default             |
|-------------|-------------------|---------------------|
| `FILE_PATH` | File to highlight | `output/output.txt` |
| `--help`    | Show help message | -                   |

#### Examples
Basic Usage:
```bash
# Highlight default output file
dart run bin/highlighter.dart

# Highlight specific file
dart run bin/highlighter.dart output/output.txt

# Highlight custom log file
dart run bin/highlighter.dart my_formatted_logs.txt
```

Advanced Usage:
```bash
# Highlight file from different directory
dart run bin/highlighter.dart ../other_project/output.txt

# Show help
dart run bin/highlighter.dart --help
```

With Compiled Binary:
```
Will be added soon
```

Color Scheme
The highlighter uses the following color scheme:
* *Blue* `[INFO]` - Severity levels
* *Green* `(05.10.25 12:00:00:000)` - Timestamps
* *Red* `<Mozilla/5.0...>` - User agents
* *Default* - Log message content

### Integration with Other Tools
```bash
# Pipe to grep for filtering
dart run bin/highlighter.dart output/output.txt | grep "WARNING"

# Count occurrences of specific messages
dart run bin/highlighter.dart output/output.txt | grep -c "user"
```

<a name="outputs"></a>
## 📊 Output
The parser generates multiple output files organized in the specified output directory. Each file serves a different purpose and format for various use cases.

### Output Directory Structure
```
output/
├── output.txt           # Formatted text logs
├── output.json          # Structured JSON data
├── json_payloads.json   # Parsed JSON payloads
├── errors.txt           # Processing errors
└── run-log.txt          # Execution log
```

### File Details

#### `output.txt` - Formatted Text Logs
Human-readable formatted logs with consistent structure. Format:

```
(TIMESTAMP) [SEVERITY] <USER_AGENT> LOG_MESSAGE
```

Example:

```
(05.10.23 12:00:00:123) [INFO] <Mozilla/5.0...> User authentication successful
(05.10.23 12:01:30:456) [ERROR] <curl/7.68.0> Database connection timeout
(05.10.23 12:02:15:789) [WARNING] <N/A> High memory usage: 85%
```

Features:
* Timestamps formatted as `DD.MM.YY HH:MM:SS:mmm`
* User agents shortened to 12 characters with ellipsis
* Consistent spacing and alignment

Ready for terminal display or logging systems

#### `output.json` - Structured JSON Data
Complete structured data preserving all original fields in a normalized format.

Format:
```json
[
  {
    "Severity": "INFO",
    "Agent": "APIs-Google; (+https://developers.google.com/webmasters/APIs-Google.html)",
    "Time": "05.10.23 12:00:00:123",
    "log": "User authentication successful"
  },
  {
    "Severity": "ERROR",
    "Time": "05.10.23 12:01:30:456",
    "log": "Database connection timeout"
  }
]
```

Fields:
* `severity` - Log level (INFO, ERROR, WARNING, etc.)
* `agent` - Full user agent string (not shortened)
* `time` - Formatted timestamp
* `log` - Log message content

#### `json_payloads.json` - Parsed JSON Payloads
Specialized output for logs that contain JSON payloads, with the JSON properly parsed and formatted.

Format:
```json
[
  {
    "Severity": "ERROR",
    "Agent": "curl/7.68.0",
    "Time": "05.10.23 12:01:30:456",
    "log": {
      "message": "Database connection timeout",
      "errorCode": "DB_CONN_001",
      "details": {
        "host": "db-server-1",
        "port": 5432
      }
    }
  }
]
```
Features:
* JSON payloads are parsed into proper objects
* Maintains original JSON structure
* Ideal for data analysis and processing
* Only includes entries with JSON payloads

#### `errors.txt` - Processing Errors
Detailed error information for log entries that couldn't be processed.

Format:
```text
Ошибка обработки элемента с индексом 0:
Тип ошибки: FormatException
Сообщение: Invalid JSON format
Элемент: { malformed json }
Stack trace: ...
------------------------
```
Contains:

* Error index (position in input file)
* Error type and message
* Problematic log entry
* Stack trace for debugging
* Separators between different errors

#### `run-log.txt` - Execution Log
Comprehensive log of the parsing execution with statistics and timing.

Format:
```
Google Cloud Log Parser
=======================
Входной файл: input.json
Выходная директория: output

Начата обработка 150 записей...
Ошибка в элементе 42: FormatException: Invalid timestamp
✓ Текстовый результат сохранен в output/output.txt
✓ JSON результат сохранен в output/output.json
✓ Логи с JSON-подобным payload сохранены в output/json_payloads.json
Найдено 23 логов с JSON-подобным payload.
⚠ Найдено 1 ошибок. Подробности в output/errors.txt

Обработка завершена!
✓ Успешно обработано: 149 из 150 элементов
✓ Отфильтровано: 5 элементов
⚠ С ошибками: 1 элементов
```

Includes:
* Start and end timestamps
* Input/output file paths
* Processing statistics
* Success/failure messages
* Error summaries

<a name="building-from-source"></a>
## 🏗️ Building from Source
```
Will be added soon
```


<a name="author"></a>
## 👨‍💻 Author

Oleg Uvarov
- Email: uv.ol.al@gmail.com
- GitHub: [@LazyLazyMeat](https://github.com/LazyLazyMeat)


<a name="license"></a>
## 📜 License

This project is licensed under the **GNU General Public License v3.0**.  
See the [LICENSE](LICENSE) file for the full text.

### What this means:
- ✅ You can use, modify, and distribute this software
- ✅ You can use this in personal projects
- 📝 If you modify and distribute this software, you **must**:
    - Make the source code available under GPL v3
    - Include the original copyright notice
    - State the changes you made

<a name="todo"></a>
## 🚧 TO-DO
* Add scripts for copying binaries to system bin directory or adding to PATH for Linux
* Develop equivalent solution for Windows
* Upload compiled binaries to GitHub releases
* Consider adding macOS support
* Translate all strings in source code to English
* Consider localization implementation
* Create Russian-language README
* Move configuration to separate config file
* Rename execution log to run.log (possibly move to logs folder and use timestamps for naming)
