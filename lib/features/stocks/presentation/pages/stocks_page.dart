import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../indices/presentation/bloc/indices_bloc.dart';
import '../../../indices/presentation/bloc/indices_event.dart';
import '../../../indices/presentation/widgets/connection_banner_widget.dart';
import '../../../indices/presentation/widgets/indices_widget.dart';
import '../bloc/stocks_bloc.dart';
import '../bloc/stocks_event.dart';
import '../bloc/stocks_state.dart';
import '../widgets/market_header_widget.dart';
import '../widgets/stocks_widget.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    context.read<IndicesBloc>().add(const GetIndicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Markets".textLarge(),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: BlocConsumer<StocksBloc, StocksState>(
        listenWhen: (previous, current) => current is StocksError,
        listener: (context, state) {
          if (state is StocksError) {
            SnackbarHelper.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is StocksLoading) {
            return const LoadingWidget(message: 'Loading market data...');
          }

          if (state is StocksError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<StocksBloc>().add(const GetStocksEvent());
              },
            );
          }

          if (state is! StocksLoaded || !state.hasData) {
            return const EmptyWidget(message: 'No market data available.');
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<IndicesBloc>().add(const GetIndicesEvent());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: MarketHeader(stocks: state.stocks.length),
                ),
                const SliverToBoxAdapter(child: ConnectionBannerWidget()),
                _headingText(text: 'Live indices', context: context),
                const SliverToBoxAdapter(child: IndicesWidget()),
                _headingText(text: 'Stocks', context: context),
                StocksWidget(stocks: state.stocks),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _headingText({
    required String text,
    required BuildContext context,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: text.textExtraLarge(fontSize: 20),
      ),
    );
  }
}
