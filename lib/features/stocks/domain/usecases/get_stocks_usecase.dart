import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock_entity.dart';
import '../repositories/stocks_repository.dart';

class GetStocksUseCase implements UseCase<List<StockEntity>, NoParams> {
  final StocksRepository repository;

  const GetStocksUseCase(this.repository);

  @override
  Future<Either<Failure, List<StockEntity>>> call(NoParams params) {
    return repository.getStocks();
  }
}
