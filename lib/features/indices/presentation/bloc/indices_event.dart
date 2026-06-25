import 'package:equatable/equatable.dart';

import '../../../../core/services/market_socket_service.dart';

abstract class IndicesEvent extends Equatable {
  const IndicesEvent();

  @override
  List<Object?> get props => [];
}

class GetIndicesEvent extends IndicesEvent {
  const GetIndicesEvent();
}

class IndicesSocketEventReceived extends IndicesEvent {
  final MarketSocketEvent socketEvent;

  const IndicesSocketEventReceived(this.socketEvent);

  @override
  List<Object?> get props => [socketEvent];
}
