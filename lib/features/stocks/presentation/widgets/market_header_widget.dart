import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';

class MarketHeader extends StatelessWidget {
  final int stocks;

  const MarketHeader({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'Stock Watch'.textExtraLarge(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 6),
                  '$stocks companies from the dataset'.textRegular(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.candlestick_chart_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }
}
