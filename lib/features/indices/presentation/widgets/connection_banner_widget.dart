import 'package:flutter/material.dart';
import 'package:flutter_assignment/core/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/market_socket_service.dart';
import '../bloc/indices_bloc.dart';
import '../bloc/indices_event.dart';
import '../bloc/indices_state.dart';

class ConnectionBannerWidget extends StatelessWidget {
  const ConnectionBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<IndicesBloc, IndicesState, _ConnectionViewData>(
      selector: (state) {
        if (state is IndicesLoaded) {
          return _ConnectionViewData(
            status: state.socketStatus,
            message: state.errorMessage,
          );
        }
        if (state is IndicesError) {
          return _ConnectionViewData(
            status: MarketSocketStatus.failed,
            message: state.message,
          );
        }
        if (state is IndicesLoading) {
          return const _ConnectionViewData(
            status: MarketSocketStatus.connecting,
          );
        }
        return const _ConnectionViewData(status: MarketSocketStatus.idle);
      },
      builder: (context, data) {
        final colorScheme = Theme.of(context).colorScheme;
        final isProblem =
            data.status == MarketSocketStatus.failed ||
            data.status == MarketSocketStatus.disconnected;
        final isConnecting =
            data.status == MarketSocketStatus.connecting ||
            data.status == MarketSocketStatus.reconnecting;
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
              Expanded(child: _labelFor(data).textMedium(color: color)),
              if (isProblem)
                TextButton(
                  onPressed: () {
                    context.read<IndicesBloc>().add(const GetIndicesEvent());
                  },
                  child: 'Retry'.textMedium(),
                ),
            ],
          ),
        );
      },
    );
  }

  String _labelFor(_ConnectionViewData data) {
    return switch (data.status) {
      MarketSocketStatus.connected => 'Live updates connected',
      MarketSocketStatus.connecting => 'Connecting to live updates...',
      MarketSocketStatus.reconnecting => 'Reconnecting to live updates...',
      MarketSocketStatus.disconnected =>
        data.message ?? 'Live updates disconnected',
      MarketSocketStatus.failed => data.message ?? 'Live updates unavailable',
      MarketSocketStatus.idle => 'Preparing live updates...',
    };
  }
}

class _ConnectionViewData {
  final MarketSocketStatus status;
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
