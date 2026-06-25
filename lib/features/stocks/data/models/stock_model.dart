import '../../domain/entities/stock_entity.dart';

class StockModel extends StockEntity {
  const StockModel({
    required super.symbol,
    required super.ss,
    required super.exchange,
    required super.type,
    required super.holdings,
    required super.currentPrice,
    required super.priceChange,
    required super.percentageChange,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] as String? ?? '',
      ss: json['ss'] as String? ?? '',
      exchange: json['exchange'] as String? ?? '',
      type: json['type'] as String? ?? '',
      holdings: int.tryParse(json['holdings'] as String? ?? '0') ?? 0,
      currentPrice: _toDouble(json['ltp']),
      priceChange: _toDouble(json['ptsC']),
      percentageChange: _toDouble(json['chgp']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
}
