import 'package:equatable/equatable.dart';

import '../../domain/entities/live_indices_event.dart';

abstract class IndicesEvent extends Equatable {
  const IndicesEvent();

  @override
  List<Object?> get props => [];
}

class GetIndicesEvent extends IndicesEvent {
  const GetIndicesEvent();
}

class IndicesSocketEventReceived extends IndicesEvent {
  final LiveIndicesEvent socketEvent;

  const IndicesSocketEventReceived(this.socketEvent);

  @override
  List<Object?> get props => [socketEvent];
}
