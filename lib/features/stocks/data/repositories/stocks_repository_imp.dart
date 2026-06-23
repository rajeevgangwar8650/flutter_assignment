import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/stocks_entity.dart';
import '../../domain/repositories/stocks_repository.dart';
import '../data_sources/stocks_data_source.dart';

class StocksRepositoryImpl implements StocksRepository {
  final StocksDataSource dataSource;

  const StocksRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, StockDashboardEntity>> getStockDashboard() async {
    try {
      return Right(await dataSource.getStockDashboard());
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Stream<StockSocketEventEntity> watchLiveIndices() {
    return dataSource.watchLiveIndices();
  }

  @override
  Future<Either<Failure, void>> connectLiveIndices(List<String> symbols) async {
    try {
      await dataSource.connectLiveIndices(symbols);
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectLiveIndices() async {
    try {
      await dataSource.disconnectLiveIndices();
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }
}
