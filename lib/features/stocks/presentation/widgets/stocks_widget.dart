import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/utils/market_formatters.dart';
import '../../domain/entities/stock_entity.dart';

class StocksWidget extends StatelessWidget {
  final List<StockEntity> stocks;

  const StocksWidget({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyWidget(message: 'No stocks available.'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid.builder(
        itemCount: stocks.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 128,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) => StockListCard(stock: stocks[index]),
      ),
    );
  }
}

class StockListCard extends StatelessWidget {
  final StockEntity stock;

  const StockListCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final changeColor = stock.isPositive
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: stock.symbol.textMedium(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _Pill(label: stock.exchange),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _formatCurrency(
                    stock.currentPrice,
                  ).textExtraLarge(fontSize: 20),
                ),
                '${formatMarketSigned(stock.priceChange)} (${formatMarketSigned(stock.percentageChange)}%)'
                    .textRegular(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                    ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  stock.hasHoldings
                      ? Icons.account_balance_wallet_outlined
                      : Icons.show_chart,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child:
                      (stock.hasHoldings
                              ? 'Holdings: ${stock.holdings}'
                              : 'No holdings')
                          .textSmall(color: colorScheme.onSurfaceVariant),
                ),
                stock.type.textSmall(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: label.textSmall(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _formatCurrency(double value) => 'Rs ${formatMarketNumber(value)}';
