import 'package:intl/intl.dart';

/// AppFormatters provides consistent date and number formatters across PoultryCare.
class AppFormatters {
  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM dd, yyyy - hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');

  static String formatDate(DateTime dt) => _shortDate.format(dt);
  static String formatDateTime(DateTime dt) => _dateTime.format(dt);
  static String formatTime(DateTime dt) => _timeOnly.format(dt);

  static String formatConfidence(double? confidence) {
    if (confidence == null) return 'N/A';
    final percentage = (confidence * 100).clamp(0.0, 100.0);
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }
}
