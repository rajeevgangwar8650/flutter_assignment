import 'package:equatable/equatable.dart';

import '../../domain/entities/stocks_entity.dart';

abstract class StocksEvent extends Equatable {
  const StocksEvent();

  @override
  List<Object?> get props => [];
}

class StocksStarted extends StocksEvent {
  const StocksStarted();
}

class StocksRetryRequested extends StocksEvent {
  const StocksRetryRequested();
}

class StocksSocketEventReceived extends StocksEvent {
  final StockSocketEventEntity socketEvent;

  const StocksSocketEventReceived(this.socketEvent);

  @override
  List<Object?> get props => [socketEvent];
}
