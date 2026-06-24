import 'package:flutter/material.dart';
import 'package:flutter_assignment/features/stocks/presentation/widgets/stocks_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../domain/entities/stocks_entity.dart';
import '../bloc/stocks_bloc.dart';
import '../bloc/stocks_state.dart';

class IndicesWidget extends StatelessWidget {
  const IndicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StocksBloc, StocksState>(
      buildWhen: (previous, current) =>
          previous.indexOrder != current.indexOrder ||
          previous.indicesBySymbol != current.indicesBySymbol,
      builder: (context, state) {
        final indices = state.indices;
        if (indices.isEmpty) {
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
            itemCount: indices.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final liveIndex = indices[index];
              return LiveIndexCard(
                key: ValueKey(liveIndex.ss),
                index: liveIndex,
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
  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final colorScheme = Theme.of(context).colorScheme;
    final changeColor = index.isPositive
        ? Colors.green.shade700
        : Colors.red.shade700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 222,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: changeColor.withValues(alpha: 0.1),
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
            formatNumber(index.currentValue),
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
                  '${formatSigned(index.change)} (${formatSigned(index.changePercent)}%)',
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
