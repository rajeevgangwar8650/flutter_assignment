import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/market_socket_service.dart';
import '../../domain/entities/index_entity.dart';
import '../../domain/repositories/indices_repository.dart';
import '../datasources/indices_local_datasource.dart';

class IndicesRepositoryImpl implements IndicesRepository {
  final IndicesLocalDataSource localDataSource;
  final MarketSocketService socketService;
  final NetworkInfo networkInfo;

  const IndicesRepositoryImpl({
    required this.localDataSource,
    required this.socketService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<IndexEntity>>> getIndices() async {
    try {
      return Right(await localDataSource.getIndices());
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Stream<MarketSocketEvent> watchLiveIndices() {
    return socketService.stream;
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
      await socketService.connect(symbols);
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectLiveIndices() async {
    try {
      await socketService.dispose();
      return const Right(null);
    } catch (error) {
      return Left(ErrorHandler.toFailure(error));
    }
  }
}
