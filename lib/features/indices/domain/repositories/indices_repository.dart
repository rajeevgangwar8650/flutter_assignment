import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/market_socket_service.dart';
import '../entities/index_entity.dart';

abstract class IndicesRepository {
  Future<Either<Failure, List<IndexEntity>>> getIndices();

  Stream<MarketSocketEvent> watchLiveIndices();

  Future<Either<Failure, void>> connectLiveIndices(List<String> symbols);

  Future<Either<Failure, void>> disconnectLiveIndices();
}
