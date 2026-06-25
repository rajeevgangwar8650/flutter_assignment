import 'package:equatable/equatable.dart';

class IndexEntity extends Equatable {
  final String symbol;
  final String token;
  final String ss;
  final double currentValue;
  final double change;
  final double changePercent;
  final double previousClose;
  final double open;
  final double high;
  final double low;
  final double close;
  final IndexPriceDirection direction;

  const IndexEntity({
    required this.symbol,
    required this.token,
    required this.ss,
    required this.currentValue,
    required this.change,
    required this.changePercent,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.direction = IndexPriceDirection.neutral,
  });

  bool get isPositive => change >= 0;

  IndexEntity copyWith({
    String? symbol,
    String? token,
    String? ss,
    double? currentValue,
    double? change,
    double? changePercent,
    double? previousClose,
    double? open,
    double? high,
    double? low,
    double? close,
    IndexPriceDirection? direction,
  }) {
    return IndexEntity(
      symbol: symbol ?? this.symbol,
      token: token ?? this.token,
      ss: ss ?? this.ss,
      currentValue: currentValue ?? this.currentValue,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object> get props => [
    symbol,
    token,
    ss,
    currentValue,
    change,
    changePercent,
    previousClose,
    open,
    high,
    low,
    close,
    direction,
  ];
}

enum IndexPriceDirection { up, down, neutral }
