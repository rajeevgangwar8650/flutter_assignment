import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/empty_widget.dart';
import '../../domain/entities/stocks_entity.dart';
import '../bloc/stocks_bloc.dart';
import '../bloc/stocks_event.dart';
import '../bloc/stocks_state.dart';

class StockConnectionBanner extends StatelessWidget {
  const StockConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StocksBloc, StocksState, _ConnectionViewData>(
      selector: (state) => _ConnectionViewData(
        status: state.socketStatus,
        message: state.errorMessage,
      ),
      builder: (context, data) {
        final colorScheme = Theme.of(context).colorScheme;
        final isProblem =
            data.status == StockSocketStatus.failed ||
            data.status == StockSocketStatus.disconnected;
        final isConnecting =
            data.status == StockSocketStatus.connecting ||
            data.status == StockSocketStatus.reconnecting;
        final color = isProblem
            ? colorScheme.error
            : isConnecting
            ? colorScheme.tertiary
            : Colors.green.shade700;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(
                isProblem
                    ? Icons.wifi_off_outlined
                    : isConnecting
                    ? Icons.sync
                    : Icons.sensors,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _labelFor(data),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isProblem)
                TextButton(
                  onPressed: () {
                    context.read<StocksBloc>().add(
                      const StocksRetryRequested(),
                    );
                  },
                  child: const Text('Retry'),
                ),
            ],
          ),
        );
      },
    );
  }

  String _labelFor(_ConnectionViewData data) {
    return switch (data.status) {
      StockSocketStatus.connected => 'Live updates connected',
      StockSocketStatus.connecting => 'Connecting to live updates...',
      StockSocketStatus.reconnecting => 'Reconnecting to live updates...',
      StockSocketStatus.disconnected =>
        data.message ?? 'Live updates disconnected',
      StockSocketStatus.failed => data.message ?? 'Live updates unavailable',
      StockSocketStatus.idle => 'Preparing live updates...',
    };
  }
}

class StockIndexStrip extends StatelessWidget {
  const StockIndexStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StocksBloc, StocksState, List<String>>(
      selector: (state) => state.indexOrder,
      builder: (context, symbols) {
        if (symbols.isEmpty) {
          return const SizedBox(
            height: 150,
            child: EmptyWidget(message: 'No indices available.'),
          );
        }

        return SizedBox(
          height: 154,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: symbols.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final symbol = symbols[index];
              return BlocSelector<StocksBloc, StocksState, StockIndexEntity?>(
                selector: (state) => state.indicesBySymbol[symbol],
                builder: (context, indexEntity) {
                  if (indexEntity == null) return const SizedBox.shrink();
                  return LiveIndexCard(
                    key: ValueKey(symbol),
                    index: indexEntity,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class LiveIndexCard extends StatefulWidget {
  final StockIndexEntity index;

  const LiveIndexCard({super.key, required this.index});

  @override
  State<LiveIndexCard> createState() => _LiveIndexCardState();
}

class _LiveIndexCardState extends State<LiveIndexCard> {
  Timer? _flashTimer;
  Color? _flashColor;

  @override
  void didUpdateWidget(covariant LiveIndexCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index.currentValue == widget.index.currentValue) return;

    final direction = widget.index.currentValue > oldWidget.index.currentValue
        ? PriceDirection.up
        : PriceDirection.down;
    _flashTimer?.cancel();
    setState(() {
      _flashColor = direction == PriceDirection.up
          ? Colors.green.withValues(alpha: 0.18)
          : Colors.red.withValues(alpha: 0.18);
    });
    _flashTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _flashColor = null);
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final colorScheme = Theme.of(context).colorScheme;
    final changeColor = index.isPositive
        ? Colors.green.shade700
        : Colors.red.shade700;
    final backgroundColor = _flashColor ?? colorScheme.surfaceContainerHighest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 222,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index.symbol,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            _formatNumber(index.currentValue),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                index.isPositive ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: changeColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${_formatSigned(index.change)} (${_formatSigned(index.changePercent)}%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StockGridSliver extends StatelessWidget {
  final List<StockItemEntity> stocks;

  const StockGridSliver({super.key, required this.stocks});

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
  final StockItemEntity stock;

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
                  child: Text(
                    stock.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _Pill(label: stock.exchange),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatCurrency(stock.currentPrice),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${_formatSigned(stock.priceChange)} (${_formatSigned(stock.percentageChange)}%)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                  ),
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
                  child: Text(
                    stock.hasHoldings
                        ? 'Holdings: ${stock.holdings}'
                        : 'No holdings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  stock.type,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
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
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ConnectionViewData {
  final StockSocketStatus status;
  final String? message;

  const _ConnectionViewData({required this.status, this.message});

  @override
  bool operator ==(Object other) {
    return other is _ConnectionViewData &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(status, message);
}

String _formatCurrency(double value) => 'Rs ${_formatNumber(value)}';

String _formatNumber(double value) => value.toStringAsFixed(2);

String _formatSigned(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}';
}
