import 'package:equatable/equatable.dart';

class StockEntity extends Equatable {
  final String symbol;
  final String ss;
  final String exchange;
  final String type;
  final int holdings;
  final double currentPrice;
  final double priceChange;
  final double percentageChange;

  const StockEntity({
    required this.symbol,
    required this.ss,
    required this.exchange,
    required this.type,
    required this.holdings,
    required this.currentPrice,
    required this.priceChange,
    required this.percentageChange,
  });

  bool get hasHoldings => holdings > 0;

  bool get isPositive => priceChange >= 0;

  StockEntity copyWith({
    String? symbol,
    String? ss,
    String? exchange,
    String? type,
    int? holdings,
    double? currentPrice,
    double? priceChange,
    double? percentageChange,
  }) {
    return StockEntity(
      symbol: symbol ?? this.symbol,
      ss: ss ?? this.ss,
      exchange: exchange ?? this.exchange,
      type: type ?? this.type,
      holdings: holdings ?? this.holdings,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      percentageChange: percentageChange ?? this.percentageChange,
    );
  }

  @override
  List<Object> get props => [
    symbol,
    ss,
    exchange,
    type,
    holdings,
    currentPrice,
    priceChange,
    percentageChange,
  ];
}
