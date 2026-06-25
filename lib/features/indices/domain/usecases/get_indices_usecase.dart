import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/market_socket_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/index_entity.dart';
import '../repositories/indices_repository.dart';

class GetIndicesUseCase implements UseCase<List<IndexEntity>, NoParams> {
  final IndicesRepository repository;

  const GetIndicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<IndexEntity>>> call(NoParams params) {
    return repository.getIndices();
  }
}

class ConnectLiveIndicesUseCase implements UseCase<void, LiveIndicesParams> {
  final IndicesRepository repository;

  const ConnectLiveIndicesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LiveIndicesParams params) {
    return repository.connectLiveIndices(params.symbols);
  }
}

class DisconnectLiveIndicesUseCase implements UseCase<void, NoParams> {
  final IndicesRepository repository;

  const DisconnectLiveIndicesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.disconnectLiveIndices();
  }
}

class WatchLiveIndicesUseCase {
  final IndicesRepository repository;

  const WatchLiveIndicesUseCase(this.repository);

  Stream<MarketSocketEvent> call() {
    return repository.watchLiveIndices();
  }
}

class LiveIndicesParams extends Equatable {
  final List<String> symbols;

  const LiveIndicesParams(this.symbols);

  @override
  List<Object> get props => [symbols];
}
