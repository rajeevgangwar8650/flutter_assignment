import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/repositories/stocks_repository.dart';
import '../datasources/stocks_local_datasource.dart';

class StocksRepositoryImpl implements StocksRepository {
  final StocksLocalDataSource localDataSource;

  const StocksRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<StockEntity>>> getStocks() async {
    try {
      return Right(await localDataSource.getStocks());
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }
}
