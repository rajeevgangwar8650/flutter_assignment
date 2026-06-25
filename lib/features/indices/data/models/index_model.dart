import '../../domain/entities/index_entity.dart';

class IndexModel extends IndexEntity {
  const IndexModel({
    required super.symbol,
    required super.token,
    required super.ss,
    required super.currentValue,
    required super.change,
    required super.changePercent,
    required super.previousClose,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
  });

  factory IndexModel.fromJson(Map<String, dynamic> json) {
    return IndexModel(
      symbol: json['symbol'] as String? ?? '',
      token: json['token'] as String? ?? '',
      ss: json['ss'] as String? ?? '',
      currentValue: _toDouble(json['ltp']),
      change: _toDouble(json['chg']),
      changePercent: _toDouble(json['chgp']),
      previousClose: _toDouble(json['pclose']),
      open: _toDouble(json['open']),
      high: _toDouble(json['high']),
      low: _toDouble(json['low']),
      close: _toDouble(json['close']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
}
