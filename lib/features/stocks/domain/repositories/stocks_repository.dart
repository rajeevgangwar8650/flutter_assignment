import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stocks_entity.dart';

abstract class StocksRepository {
  Future<Either<Failure, StockDashboardEntity>> getStockDashboard();

  Stream<StockSocketEventEntity> watchLiveIndices();

  Future<Either<Failure, void>> connectLiveIndices(List<String> symbols);

  Future<Either<Failure, void>> disconnectLiveIndices();
}
