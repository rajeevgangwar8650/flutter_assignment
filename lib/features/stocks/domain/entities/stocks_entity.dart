import 'package:equatable/equatable.dart';

class StockDashboardEntity extends Equatable {
  final List<StockIndexEntity> indices;
  final List<StockItemEntity> stocks;

  const StockDashboardEntity({
    required this.indices,
    required this.stocks,
  });

  @override
  List<Object> get props => [indices, stocks];
}

class StockIndexEntity extends Equatable {
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
  final PriceDirection direction;

  const StockIndexEntity({
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
    this.direction = PriceDirection.neutral,
  });

  bool get isPositive => change >= 0;

  StockIndexEntity copyWith({
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
    PriceDirection? direction,
  }) {
    return StockIndexEntity(
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

class StockItemEntity extends Equatable {
  final String symbol;
  final String ss;
  final String exchange;
  final String type;
  final int holdings;
  final double currentPrice;
  final double priceChange;
  final double percentageChange;

  const StockItemEntity({
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

  StockItemEntity copyWith({
    String? symbol,
    String? ss,
    String? exchange,
    String? type,
    int? holdings,
    double? currentPrice,
    double? priceChange,
    double? percentageChange,
  }) {
    return StockItemEntity(
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

class StockTickEntity extends Equatable {
  final String name;
  final double currentValue;
  final double high;
  final double low;
  final double open;
  final double close;
  final double changePercent;

  const StockTickEntity({
    required this.name,
    required this.currentValue,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.changePercent,
  });

  @override
  List<Object> get props => [
    name,
    currentValue,
    high,
    low,
    open,
    close,
    changePercent,
  ];
}

class StockSocketEventEntity extends Equatable {
  final StockSocketStatus status;
  final StockTickEntity? tick;
  final String? message;

  const StockSocketEventEntity({required this.status, this.tick, this.message});

  @override
  List<Object?> get props => [status, tick, message];
}

enum PriceDirection { up, down, neutral }

enum StockSocketStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}
