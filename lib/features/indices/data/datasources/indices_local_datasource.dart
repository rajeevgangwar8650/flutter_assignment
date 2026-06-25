import '../../../../core/constants/market_seed_data.dart';
import '../models/index_model.dart';

abstract class IndicesLocalDataSource {
  Future<List<IndexModel>> getIndices();
}

class IndicesLocalDataSourceImpl implements IndicesLocalDataSource {
  const IndicesLocalDataSourceImpl();

  @override
  Future<List<IndexModel>> getIndices() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final rawIndices = marketSeedData['indices'] as List<dynamic>? ?? const [];
    return rawIndices
        .whereType<Map<String, dynamic>>()
        .map(IndexModel.fromJson)
        .toList(growable: false);
  }
}
