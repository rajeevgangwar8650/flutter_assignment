class WordCountHelper {
  static int count(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static String truncateToMaxWords(String text, int maxWords) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text.trim();
    return words.take(maxWords).join(' ');
  }
}
