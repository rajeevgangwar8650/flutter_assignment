import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/index_entity.dart';
import '../entities/live_indices_event.dart';

abstract class IndicesRepository {
  Future<Either<Failure, List<IndexEntity>>> getIndices();

  Stream<LiveIndicesEvent> watchLiveIndices();

  Future<Either<Failure, void>> connectLiveIndices(List<String> symbols);

  Future<Either<Failure, void>> disconnectLiveIndices();
}
