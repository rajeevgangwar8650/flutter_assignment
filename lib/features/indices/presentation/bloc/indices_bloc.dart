import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/market_socket_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/index_entity.dart';
import '../../domain/usecases/get_indices_usecase.dart';
import 'indices_event.dart';
import 'indices_state.dart';

class IndicesBloc extends Bloc<IndicesEvent, IndicesState> {
  static const List<String> _extraLiveFeedSymbols = ['BSEIDX_1'];

  final GetIndicesUseCase getIndicesUseCase;
  final ConnectLiveIndicesUseCase connectLiveIndicesUseCase;
  final DisconnectLiveIndicesUseCase disconnectLiveIndicesUseCase;
  final WatchLiveIndicesUseCase watchLiveIndicesUseCase;

  StreamSubscription<MarketSocketEvent>? _socketSubscription;

  IndicesBloc({
    required this.getIndicesUseCase,
    required this.connectLiveIndicesUseCase,
    required this.disconnectLiveIndicesUseCase,
    required this.watchLiveIndicesUseCase,
  }) : super(const IndicesInitial()) {
    on<GetIndicesEvent>(_onGetIndices);
    on<IndicesSocketEventReceived>(_onSocketEventReceived);
  }

  Future<void> _onGetIndices(
    GetIndicesEvent event,
    Emitter<IndicesState> emit,
  ) async {
    final currentState = state;
    if (currentState is IndicesLoading) return;

    if (currentState is IndicesLoaded && currentState.hasData) {
      emit(
        currentState.copyWith(
          socketStatus: MarketSocketStatus.reconnecting,
          clearError: true,
        ),
      );
      await _ensureSocketSubscription();
      await _connectLiveIndices(currentState.indices, emit);
      return;
    }

    emit(const IndicesLoading());
    await _ensureSocketSubscription();

    final result = await getIndicesUseCase(NoParams());
    await result.fold((failure) async => emit(IndicesError(failure.message)), (
      indices,
    ) async {
      emit(IndicesLoaded(indices: indices));
      await _connectLiveIndices(indices, emit);
    });
  }

  Future<void> _ensureSocketSubscription() async {
    await _socketSubscription?.cancel();
    _socketSubscription = watchLiveIndicesUseCase().listen((socketEvent) {
      add(IndicesSocketEventReceived(socketEvent));
    });
  }

  Future<void> _connectLiveIndices(
    List<IndexEntity> indices,
    Emitter<IndicesState> emit,
  ) async {
    final connectResult = await connectLiveIndicesUseCase(
      LiveIndicesParams(_liveFeedSymbolsFor(indices)),
    );
    connectResult.fold((failure) {
      final currentState = state;
      if (currentState is IndicesLoaded) {
        emit(
          currentState.copyWith(
            socketStatus: MarketSocketStatus.failed,
            errorMessage: failure.message,
          ),
        );
      } else {
        emit(IndicesError(failure.message));
      }
    }, (_) {});
  }

  void _onSocketEventReceived(
    IndicesSocketEventReceived event,
    Emitter<IndicesState> emit,
  ) {
    final currentState = state;
    if (currentState is! IndicesLoaded) return;

    final socketEvent = event.socketEvent;
    final tick = socketEvent.tick;

    if (tick == null) {
      final isFailure = socketEvent.status == MarketSocketStatus.failed;
      emit(
        currentState.copyWith(
          socketStatus: socketEvent.status,
          errorMessage: isFailure ? socketEvent.message : null,
          clearError: !isFailure,
        ),
      );
      return;
    }

    var matched = false;
    final updatedIndices = currentState.indices
        .map((index) {
          if (!_matchesIndex(index, tick)) return index;

          matched = true;
          return _updatedIndex(index, tick);
        })
        .toList(growable: false);

    if (!matched) {
      emit(
        currentState.copyWith(
          socketStatus: socketEvent.status,
          clearError: socketEvent.status == MarketSocketStatus.connected,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        indices: updatedIndices,
        socketStatus: MarketSocketStatus.connected,
        clearError: true,
      ),
    );
  }

  IndexEntity _updatedIndex(IndexEntity current, MarketTick tick) {
    final direction = tick.currentValue > current.currentValue
        ? IndexPriceDirection.up
        : tick.currentValue < current.currentValue
        ? IndexPriceDirection.down
        : IndexPriceDirection.neutral;

    return current.copyWith(
      currentValue: tick.currentValue,
      high: tick.high,
      low: tick.low,
      open: tick.open,
      close: tick.close,
      change: _changeForTick(tick, current.change),
      changePercent: tick.changePercent,
      direction: direction,
    );
  }

  double _changeForTick(MarketTick tick, double fallback) {
    return tick.close == 0 ? fallback : tick.currentValue - tick.close;
  }

  bool _matchesIndex(IndexEntity index, MarketTick tick) {
    final normalizedTickName = _normalizeToken(tick.name);
    return normalizedTickName == _normalizeToken(index.token) ||
        normalizedTickName == _normalizeToken(_tokenFromIdentifier(index.ss)) ||
        normalizedTickName == _normalizeToken(index.ss) ||
        _normalize(tick.name) == _normalize(index.symbol);
  }

  String _tokenFromIdentifier(String value) {
    final parts = value.split('_');
    return parts.isEmpty ? value : parts.last;
  }

  String _normalizeToken(String value) {
    return value.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<String> _liveFeedSymbolsFor(List<IndexEntity> indices) {
    return <String>{
      ...indices.map((index) => index.ss),
      ..._extraLiveFeedSymbols,
    }.where((symbol) => symbol.trim().isNotEmpty).toList(growable: false);
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    await disconnectLiveIndicesUseCase(NoParams());
    return super.close();
  }
}
