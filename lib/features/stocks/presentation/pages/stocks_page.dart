import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/stocks_bloc.dart';
import '../bloc/stocks_event.dart';
import '../bloc/stocks_state.dart';
import '../widgets/stock_market_widgets.dart';

class StocksPage extends StatelessWidget {
  const StocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: BlocConsumer<StocksBloc, StocksState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          SnackbarHelper.showError(context, state.errorMessage!);
        },
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.stocks != current.stocks ||
            previous.hasData != current.hasData ||
            previous.errorMessage != current.errorMessage,
        builder: (context, state) {
          if (state.status == StocksStatus.loading && !state.hasData) {
            return const LoadingWidget(message: 'Loading market data...');
          }

          if (state.status == StocksStatus.failure && !state.hasData) {
            return AppErrorWidget(
              message: state.errorMessage ?? 'Unable to load market data.',
              onRetry: () {
                context.read<StocksBloc>().add(const StocksRetryRequested());
              },
            );
          }

          if (!state.hasData) {
            return const EmptyWidget(message: 'No market data available.');
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<StocksBloc>().add(const StocksRetryRequested());
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _MarketHeader(stocks: state.stocks.length),
                ),
                const SliverToBoxAdapter(child: StockConnectionBanner()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Live indices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: StockIndexStrip()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Stocks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                StockGridSliver(stocks: state.stocks),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MarketHeader extends StatelessWidget {
  final int stocks;

  const _MarketHeader({required this.stocks});

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
                  Text(
                    'Stock Watch',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$stocks companies from the assignment dataset',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
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
