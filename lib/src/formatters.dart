import 'dart:convert';

String? formatTimestamp(String? timestampStr) {
  if (timestampStr == null) return null;

  try {
    DateTime date;

    if (RegExp(r'^\d+$').hasMatch(timestampStr)) {
      int timeValue = int.parse(timestampStr);

      if (timestampStr.length <= 10) {
        date = DateTime.fromMillisecondsSinceEpoch(timeValue * 1000);
      } else {
        date = DateTime.fromMillisecondsSinceEpoch(timeValue);
      }
    } else {
      date = DateTime.parse(timestampStr);
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    final millisecond = date.millisecond.toString().padLeft(3, '0');

    return '$day.$month.$year $hour:$minute:$second:$millisecond';
  } catch (e) {
    return timestampStr;
  }
}

String shortenUserAgent(String userAgent) {
  if (userAgent.length <= 12) {
    return userAgent;
  }
  return '${userAgent.substring(0, 12)}...';
}

bool isJsonLike(String text) {
  final trimmedText = text.trim();

  if (trimmedText.isEmpty) return false;

  if ((trimmedText.startsWith('{') && trimmedText.endsWith('}')) ||
      (trimmedText.startsWith('[') && trimmedText.endsWith(']'))) {
    return true;
  }

  return false;
}

dynamic tryParseJson(String text) {
  try {
    return json.decode(text);
  } catch (e) {
    return text;
  }
}
