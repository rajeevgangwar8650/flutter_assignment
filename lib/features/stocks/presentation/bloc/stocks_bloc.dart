import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/stocks_entity.dart';
import '../../domain/usecases/stocks_usecase.dart';
import 'stocks_event.dart';
import 'stocks_state.dart';

class StocksBloc extends Bloc<StocksEvent, StocksState> {
  final GetStockDashboardUseCase getStockDashboardUseCase;
  final ConnectLiveIndicesUseCase connectLiveIndicesUseCase;
  final DisconnectLiveIndicesUseCase disconnectLiveIndicesUseCase;
  final WatchLiveIndicesUseCase watchLiveIndicesUseCase;

  StreamSubscription<StockSocketEventEntity>? _socketSubscription;

  StocksBloc({
    required this.getStockDashboardUseCase,
    required this.connectLiveIndicesUseCase,
    required this.disconnectLiveIndicesUseCase,
    required this.watchLiveIndicesUseCase,
  }) : super(const StocksState.initial()) {
    on<StocksStarted>(_onStarted);
    on<StocksRetryRequested>(_onRetryRequested);
    on<StocksSocketEventReceived>(_onSocketEventReceived);
  }

  Future<void> _onStarted(
    StocksStarted event,
    Emitter<StocksState> emit,
  ) async {
    if (state.status == StocksStatus.loading) return;

    emit(state.copyWith(status: StocksStatus.loading, clearError: true));
    await _socketSubscription?.cancel();
    _socketSubscription = watchLiveIndicesUseCase().listen(
      (socketEvent) => add(StocksSocketEventReceived(socketEvent)),
    );

    final result = await getStockDashboardUseCase(NoParams());
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: StocksStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (dashboard) async {
        final indicesBySymbol = {
          for (final index in dashboard.indices) index.ss: index,
        };
        final symbols = dashboard.indices.map((index) => index.ss).toList();

        emit(
          state.copyWith(
            status: StocksStatus.success,
            indexOrder: symbols,
            indicesBySymbol: indicesBySymbol,
            stocks: dashboard.stocks,
            clearError: true,
          ),
        );

        final connectResult = await connectLiveIndicesUseCase(
          ConnectLiveIndicesParams(symbols),
        );
        connectResult.fold(
          (failure) => add(
            StocksSocketEventReceived(
              StockSocketEventEntity(
                status: StockSocketStatus.failed,
                message: failure.message,
              ),
            ),
          ),
          (_) {},
        );
      },
    );
  }

  Future<void> _onRetryRequested(
    StocksRetryRequested event,
    Emitter<StocksState> emit,
  ) async {
    if (!state.hasData) {
      add(const StocksStarted());
      return;
    }

    emit(
      state.copyWith(
        socketStatus: StockSocketStatus.reconnecting,
        clearError: true,
      ),
    );
    final connectResult = await connectLiveIndicesUseCase(
      ConnectLiveIndicesParams(state.indexOrder),
    );
    connectResult.fold(
      (failure) => emit(
        state.copyWith(
          socketStatus: StockSocketStatus.failed,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  void _onSocketEventReceived(
    StocksSocketEventReceived event,
    Emitter<StocksState> emit,
  ) {
    final socketEvent = event.socketEvent;
    final tick = socketEvent.tick;

    if (tick == null) {
      emit(
        state.copyWith(
          socketStatus: socketEvent.status,
          errorMessage:
              socketEvent.status == StockSocketStatus.failed ||
                  socketEvent.status == StockSocketStatus.disconnected
              ? socketEvent.message
              : null,
          clearError: socketEvent.status == StockSocketStatus.connected,
        ),
      );
      return;
    }

    final matchedSymbol = _findMatchingSymbol(tick);
    if (matchedSymbol == null) {
      emit(
        state.copyWith(
          socketStatus: socketEvent.status,
          clearError: socketEvent.status == StockSocketStatus.connected,
        ),
      );
      return;
    }

    final current = state.indicesBySymbol[matchedSymbol];
    if (current == null) return;

    final direction = tick.currentValue > current.currentValue
        ? PriceDirection.up
        : tick.currentValue < current.currentValue
        ? PriceDirection.down
        : PriceDirection.neutral;
    final change = tick.close == 0
        ? current.change
        : tick.currentValue - tick.close;

    final updated = current.copyWith(
      currentValue: tick.currentValue,
      high: tick.high,
      low: tick.low,
      open: tick.open,
      close: tick.close,
      change: change,
      changePercent: tick.changePercent,
      direction: direction,
    );

    if (updated == current) return;

    emit(
      state.copyWith(
        socketStatus: StockSocketStatus.connected,
        indicesBySymbol: {...state.indicesBySymbol, matchedSymbol: updated},
        clearError: true,
      ),
    );
  }

  String? _findMatchingSymbol(StockTickEntity tick) {
    final normalizedTickName = _normalize(tick.name);
    for (final entry in state.indicesBySymbol.entries) {
      if (_normalize(entry.value.symbol) == normalizedTickName) {
        return entry.key;
      }
    }
    return null;
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    await disconnectLiveIndicesUseCase(NoParams());
    return super.close();
  }
}
