import 'package:equatable/equatable.dart';

class LiveIndexTick extends Equatable {
  final String exchange;
  final String token;
  final double currentValue;
  final double high;
  final double low;
  final double open;
  final double close;
  final double changePercent;

  const LiveIndexTick({
    required this.exchange,
    required this.token,
    required this.currentValue,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.changePercent,
  });

  String get streamSymbol => '${exchange}_$token';

  @override
  List<Object> get props => [
    exchange,
    token,
    currentValue,
    high,
    low,
    open,
    close,
    changePercent,
  ];
}
