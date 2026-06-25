import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/market_formatters.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/index_entity.dart';
import '../bloc/indices_bloc.dart';
import '../bloc/indices_state.dart';

class IndicesWidget extends StatelessWidget {
  const IndicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndicesBloc, IndicesState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is IndicesLoading) {
          return const SizedBox(
            height: 150,
            child: LoadingWidget(message: 'Loading live indices...'),
          );
        }

        if (state is IndicesError) {
          return SizedBox(
            height: 150,
            child: EmptyWidget(message: state.message),
          );
        }

        final indices = state is IndicesLoaded
            ? state.indices
            : const <IndexEntity>[];
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
  final IndexEntity index;

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
          index.symbol.textMedium(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w700,
          ),
          const Spacer(),
          formatMarketNumber(index.currentValue).textExtraLarge(fontSize: 22),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                index.isPositive ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child:
                    '${formatMarketSigned(index.change)} (${formatMarketSigned(index.changePercent)}%)'
                        .textRegular(
                          maxLines: 1,
                          color: changeColor,
                          fontWeight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
