import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stocks_entity.dart';
import '../repositories/stocks_repository.dart';

class GetStockDashboardUseCase implements UseCase<StockDashboardEntity, NoParams> {
  final StocksRepository repository;

  const GetStockDashboardUseCase(this.repository);

  @override
  Future<Either<Failure, StockDashboardEntity>> call(NoParams params) {
    return repository.getStockDashboard();
  }
}

class ConnectLiveIndicesUseCase
    implements UseCase<void, ConnectLiveIndicesParams> {
  final StocksRepository repository;

  const ConnectLiveIndicesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ConnectLiveIndicesParams params) {
    return repository.connectLiveIndices(params.symbols);
  }
}

class DisconnectLiveIndicesUseCase implements UseCase<void, NoParams> {
  final StocksRepository repository;

  const DisconnectLiveIndicesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.disconnectLiveIndices();
  }
}

class WatchLiveIndicesUseCase {
  final StocksRepository repository;

  const WatchLiveIndicesUseCase(this.repository);

  Stream<StockSocketEventEntity> call() {
    return repository.watchLiveIndices();
  }
}

class ConnectLiveIndicesParams extends Equatable {
  final List<String> symbols;

  const ConnectLiveIndicesParams(this.symbols);

  @override
  List<Object> get props => [symbols];
}
