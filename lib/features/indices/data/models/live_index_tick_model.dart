import '../../domain/entities/live_index_tick.dart';

class LiveIndexTickModel extends LiveIndexTick {
  const LiveIndexTickModel({
    required super.exchange,
    required super.token,
    required super.currentValue,
    required super.high,
    required super.low,
    required super.open,
    required super.close,
    required super.changePercent,
  });

  factory LiveIndexTickModel.fromSocketPayload(String payload) {
    final parts = payload.split('|').map((part) => part.trim()).toList();
    if (parts.length < 8) {
      throw const FormatException('Invalid live index tick payload');
    }

    return LiveIndexTickModel(
      exchange: parts[0],
      token: parts[1],
      currentValue: _toDouble(parts[2]),
      high: _toDouble(parts[3]),
      low: _toDouble(parts[4]),
      open: _toDouble(parts[5]),
      close: _toDouble(parts[6]),
      changePercent: _toDouble(parts[7]),
    );
  }
}

double _toDouble(String value) {
  return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
}
