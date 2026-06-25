import 'package:equatable/equatable.dart';

import 'live_index_tick.dart';

class LiveIndicesEvent extends Equatable {
  final LiveIndicesConnectionStatus status;
  final LiveIndexTick? tick;
  final String? message;

  const LiveIndicesEvent({required this.status, this.tick, this.message});

  @override
  List<Object?> get props => [status, tick, message];
}

enum LiveIndicesConnectionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}
