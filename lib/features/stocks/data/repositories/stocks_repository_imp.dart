import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/stocks_entity.dart';
import '../../domain/repositories/stocks_repository.dart';
import '../data_sources/stocks_data_source.dart';

class StocksRepositoryImpl implements StocksRepository {
  final StocksDataSource dataSource;
  final NetworkInfo networkInfo;

  const StocksRepositoryImpl(this.dataSource, this.networkInfo);

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
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure('No internet connection. Please check your network.'),
        );
      }
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
