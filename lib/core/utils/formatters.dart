import 'package:intl/intl.dart';
import 'bidi_utils.dart';

/// AppFormatters provides consistent date and number formatters across PoultryCare.
class AppFormatters {
  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM dd, yyyy - hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');

  static String formatDate(DateTime dt) => BidiUtils.ltr(_shortDate.format(dt));
  static String formatDateTime(DateTime dt) => BidiUtils.ltr(_dateTime.format(dt));
  static String formatTime(DateTime dt) => BidiUtils.ltr(_timeOnly.format(dt));

  static String formatConfidence(double? confidence) {
    if (confidence == null) return 'N/A';
    final percentage = (confidence * 100).clamp(0.0, 100.0);
    return BidiUtils.ltr('${percentage.toStringAsFixed(1)}%');
  }

  /// Formats a scan database ID into a friendly label like "Scan #4" or "اسکین نمبر 4".
  static String formatScanId(String rawId, {bool isUrdu = false}) {
    final matches = RegExp(r'\d+').allMatches(rawId);
    final numStr = matches.isNotEmpty ? (matches.last.group(0) ?? rawId) : rawId;
    return isUrdu ? 'اسکین نمبر ${BidiUtils.ltr(numStr)}' : 'Scan #${BidiUtils.ltr(numStr)}';
  }

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return BidiUtils.ltr('${diff.inMinutes}m ago');
    if (diff.inDays < 1) return BidiUtils.ltr('${diff.inHours}h ago');
    if (diff.inDays < 7) return BidiUtils.ltr('${diff.inDays}d ago');
    return formatDate(dt);
  }
}
