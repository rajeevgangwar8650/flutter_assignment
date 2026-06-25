String formatMarketNumber(double value) => value.toStringAsFixed(2);

String formatMarketSigned(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}';
}
