import 'package:equatable/equatable.dart';

import '../../../../core/services/market_socket_service.dart';
import '../../domain/entities/index_entity.dart';

abstract class IndicesState extends Equatable {
  const IndicesState();

  @override
  List<Object?> get props => [];
}

class IndicesInitial extends IndicesState {
  const IndicesInitial();
}

class IndicesLoading extends IndicesState {
  const IndicesLoading();
}

class IndicesLoaded extends IndicesState {
  final List<IndexEntity> indices;
  final MarketSocketStatus socketStatus;
  final String? errorMessage;

  const IndicesLoaded({
    required this.indices,
    this.socketStatus = MarketSocketStatus.idle,
    this.errorMessage,
  });

  bool get hasData => indices.isNotEmpty;

  IndicesLoaded copyWith({
    List<IndexEntity>? indices,
    MarketSocketStatus? socketStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IndicesLoaded(
      indices: indices ?? this.indices,
      socketStatus: socketStatus ?? this.socketStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [indices, socketStatus, errorMessage];
}

class IndicesError extends IndicesState {
  final String message;

  const IndicesError(this.message);

  @override
  List<Object?> get props => [message];
}
