import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_stocks_usecase.dart';
import 'stocks_event.dart';
import 'stocks_state.dart';

class StocksBloc extends Bloc<StocksEvent, StocksState> {
  final GetStocksUseCase getStocksUseCase;

  StocksBloc({required this.getStocksUseCase}) : super(const StocksInitial()) {
    on<GetStocksEvent>(_onGetStocks);
  }

  Future<void> _onGetStocks(
    GetStocksEvent event,
    Emitter<StocksState> emit,
  ) async {
    if (state is StocksLoading) return;

    emit(const StocksLoading());
    final result = await getStocksUseCase(NoParams());
    result.fold(
      (failure) => emit(StocksError(failure.message)),
      (stocks) => emit(StocksLoaded(stocks: stocks)),
    );
  }
}
