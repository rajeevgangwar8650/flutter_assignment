import 'package:equatable/equatable.dart';

import '../../domain/entities/stocks_entity.dart';

class StocksState extends Equatable {
  final StocksStatus status;
  final StockSocketStatus socketStatus;
  final List<String> indexOrder;
  final Map<String, StockIndexEntity> indicesBySymbol;
  final List<StockItemEntity> stocks;
  final String? errorMessage;

  const StocksState({
    required this.status,
    required this.socketStatus,
    required this.indexOrder,
    required this.indicesBySymbol,
    required this.stocks,
    this.errorMessage,
  });

  const StocksState.initial()
    : status = StocksStatus.initial,
      socketStatus = StockSocketStatus.idle,
      indexOrder = const [],
      indicesBySymbol = const {},
      stocks = const [],
      errorMessage = null;

  List<StockIndexEntity> get indices => indexOrder
      .map((symbol) => indicesBySymbol[symbol])
      .whereType<StockIndexEntity>()
      .toList(growable: false);

  bool get hasData => indicesBySymbol.isNotEmpty || stocks.isNotEmpty;

  StocksState copyWith({
    StocksStatus? status,
    StockSocketStatus? socketStatus,
    List<String>? indexOrder,
    Map<String, StockIndexEntity>? indicesBySymbol,
    List<StockItemEntity>? stocks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StocksState(
      status: status ?? this.status,
      socketStatus: socketStatus ?? this.socketStatus,
      indexOrder: indexOrder ?? this.indexOrder,
      indicesBySymbol: indicesBySymbol ?? this.indicesBySymbol,
      stocks: stocks ?? this.stocks,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    socketStatus,
    indexOrder,
    indicesBySymbol,
    stocks,
    errorMessage,
  ];
}

enum StocksStatus { initial, loading, success, failure }
