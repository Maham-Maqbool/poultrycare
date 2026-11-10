/// Bidirectional text utilities for seamless Urdu (RTL) and English (LTR) rendering.
class BidiUtils {
  /// Wraps Latin words, numbers, percentages, times, scan IDs, and currencies in an LTR isolate
  /// to prevent punctuation and numbers from getting jumbled by the Unicode Bidi algorithm in RTL context.
  static String ltr(String text) {
    if (text.isEmpty) return text;
    // Unicode Left-to-Right Isolate (U+2066) and Pop Directional Isolate (U+2069)
    return '\u2066$text\u2069';
  }
}

