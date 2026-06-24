import '../../domain/entities/stocks_entity.dart';

class StockDashboardModel extends StockDashboardEntity {
  const StockDashboardModel({
    required super.indices,
    required super.stocks,
  });

  factory StockDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawIndices = json['indices'] as List<dynamic>? ?? const [];
    final rawStocks = json['stocks'] as List<dynamic>? ?? const [];

    return StockDashboardModel(
      indices: rawIndices
          .whereType<Map<String, dynamic>>()
          .map(StockIndexModel.fromJson)
          .toList(growable: false),
      stocks: rawStocks
          .whereType<Map<String, dynamic>>()
          .map(StockItemModel.fromJson)
          .toList(growable: false),
    );
  }
}

class StockIndexModel extends StockIndexEntity {
  const StockIndexModel({
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

  factory StockIndexModel.fromJson(Map<String, dynamic> json) {
    return StockIndexModel(
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

class StockItemModel extends StockItemEntity {
  const StockItemModel({
    required super.symbol,
    required super.ss,
    required super.exchange,
    required super.type,
    required super.holdings,
    required super.currentPrice,
    required super.priceChange,
    required super.percentageChange,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
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

class StockTickModel extends StockTickEntity {
  const StockTickModel({
    required super.name,
    required super.currentValue,
    required super.high,
    required super.low,
    required super.open,
    required super.close,
    required super.changePercent,
  });

  factory StockTickModel.fromSocketPayload(String payload) {
    final parts = payload.split('|');
    if (parts.length < 8) {
      throw const FormatException('Invalid stock tick payload');
    }

    return StockTickModel(
      name: parts[1].trim(),
      currentValue: _toDouble(parts[2]),
      high: _toDouble(parts[3]),
      low: _toDouble(parts[4]),
      open: _toDouble(parts[5]),
      close: _toDouble(parts[6]),
      changePercent: _toDouble(parts[7]),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
}
