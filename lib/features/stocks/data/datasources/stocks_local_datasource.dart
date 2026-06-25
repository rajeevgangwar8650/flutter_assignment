import '../../../../core/constants/market_seed_data.dart';
import '../models/stock_model.dart';

abstract class StocksLocalDataSource {
  Future<List<StockModel>> getStocks();
}

class StocksLocalDataSourceImpl implements StocksLocalDataSource {
  const StocksLocalDataSourceImpl();

  @override
  Future<List<StockModel>> getStocks() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final rawStocks = marketSeedData['stocks'] as List<dynamic>? ?? const [];
    return rawStocks
        .whereType<Map<String, dynamic>>()
        .map(StockModel.fromJson)
        .toList(growable: false);
  }
}
