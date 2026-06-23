import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stocks_entity.dart';
import '../bloc/stocks_bloc.dart';
import '../bloc/stocks_event.dart';
import '../bloc/stocks_state.dart';

class ConnectionBannerWidget extends StatelessWidget {
  const ConnectionBannerWidget({super.key});

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
