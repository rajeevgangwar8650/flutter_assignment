import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/stocks_entity.dart';
import '../../domain/usecases/stocks_usecase.dart';
import 'stocks_event.dart';
import 'stocks_state.dart';

class StocksBloc extends Bloc<StocksEvent, StocksState> {
  static const List<String> _extraLiveFeedSymbols = ['BSEIDX_1'];

  final GetStockDashboardUseCase getStockDashboardUseCase;
  final ConnectLiveIndicesUseCase connectLiveIndicesUseCase;
  final DisconnectLiveIndicesUseCase disconnectLiveIndicesUseCase;
  final WatchLiveIndicesUseCase watchLiveIndicesUseCase;

  StreamSubscription<StockSocketEventEntity>? _socketSubscription;
  List<String> _activeLiveFeedSymbols = const [];

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
    _socketSubscription = watchLiveIndicesUseCase().listen((socketEvent) {
      add(StocksSocketEventReceived(socketEvent));
    });

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
        final displaySymbols = dashboard.indices
            .map((index) => index.ss)
            .toList();

        emit(
          state.copyWith(
            status: StocksStatus.success,
            indexOrder: displaySymbols,
            indicesBySymbol: indicesBySymbol,
            stocks: dashboard.stocks,
            clearError: true,
          ),
        );

        _activeLiveFeedSymbols = _liveFeedSymbolsFor(
          indices: dashboard.indices,
          stocks: dashboard.stocks,
        );

        final connectResult = await connectLiveIndicesUseCase(
          ConnectLiveIndicesParams(_activeLiveFeedSymbols),
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
    final symbols = _activeLiveFeedSymbols.isNotEmpty
        ? _activeLiveFeedSymbols
        : _liveFeedSymbolsFor(indices: state.indices, stocks: state.stocks);
    final connectResult = await connectLiveIndicesUseCase(
      ConnectLiveIndicesParams(symbols),
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
      final isFailure = socketEvent.status == StockSocketStatus.failed;
      emit(
        state.copyWith(
          socketStatus: socketEvent.status,
          errorMessage: isFailure ? socketEvent.message : null,
          clearError: !isFailure,
        ),
      );
      return;
    }

    final updatedIndicesBySymbol = <String, StockIndexEntity>{};
    var indexMatched = false;

    for (final entry in state.indicesBySymbol.entries) {
      final current = entry.value;

      if (_matchesIndex(current, tick)) {
        indexMatched = true;
        final updated = _updatedIndex(current, tick);

        updatedIndicesBySymbol[entry.key] = updated;
      } else {
        updatedIndicesBySymbol[entry.key] = current;
      }
    }

    var stockMatched = false;
    final updatedStocks = state.stocks
        .map((stock) {
          if (!_matchesStock(stock, tick)) return stock;

          stockMatched = true;
          final updated = stock.copyWith(
            currentPrice: tick.currentValue,
            priceChange: _changeForTick(tick, stock.priceChange),
            percentageChange: tick.changePercent,
          );

          return updated;
        })
        .toList(growable: false);

    if (!indexMatched && !stockMatched) {
      final noMatchState = state.copyWith(
        socketStatus: socketEvent.status,
        clearError: socketEvent.status == StockSocketStatus.connected,
      );
      emit(noMatchState);
      return;
    }

    emit(
      state.copyWith(
        socketStatus: StockSocketStatus.connected,
        indicesBySymbol: updatedIndicesBySymbol,
        stocks: updatedStocks,
        clearError: true,
      ),
    );
  }

  StockIndexEntity _updatedIndex(
    StockIndexEntity current,
    StockTickEntity tick,
  ) {
    final direction = tick.currentValue > current.currentValue
        ? PriceDirection.up
        : tick.currentValue < current.currentValue
        ? PriceDirection.down
        : PriceDirection.neutral;

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

  double _changeForTick(StockTickEntity tick, double fallback) {
    return tick.close == 0 ? fallback : tick.currentValue - tick.close;
  }

  bool _matchesIndex(StockIndexEntity index, StockTickEntity tick) {
    final normalizedTickName = _normalizeToken(tick.name);
    return normalizedTickName == _normalizeToken(index.token) ||
        normalizedTickName == _normalizeToken(_tokenFromIdentifier(index.ss)) ||
        normalizedTickName == _normalizeToken(index.ss) ||
        _normalize(tick.name) == _normalize(index.symbol);
  }

  bool _matchesStock(StockItemEntity stock, StockTickEntity tick) {
    final normalizedTickName = _normalizeToken(tick.name);
    return normalizedTickName ==
            _normalizeToken(_tokenFromIdentifier(stock.ss)) ||
        normalizedTickName == _normalizeToken(stock.ss) ||
        _normalize(tick.name) == _normalize(stock.symbol);
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

  List<String> _liveFeedSymbolsFor({
    required List<StockIndexEntity> indices,
    required List<StockItemEntity> stocks,
  }) {
    final symbols = <String>{
      ...indices.map((index) => index.ss),
      ...stocks.map((stock) => stock.ss),
      ..._extraLiveFeedSymbols,
    }.where((symbol) => symbol.trim().isNotEmpty).toList(growable: false);
    return symbols;
  }

  @override
  Future<void> close() async {
    await _socketSubscription?.cancel();
    await disconnectLiveIndicesUseCase(NoParams());
    return super.close();
  }
}
