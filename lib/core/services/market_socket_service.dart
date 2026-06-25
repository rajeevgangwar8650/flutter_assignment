import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';

class MarketSocketService {
  static final Uri _socketUri = Uri.parse(ApiConstants.socketUrl);
  static const int _maxReconnectAttempts = 5;

  final StreamController<MarketSocketEvent> _controller =
      StreamController<MarketSocketEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  List<String> _symbols = const [];
  int _reconnectAttempts = 0;
  bool _manualClose = false;

  Stream<MarketSocketEvent> get stream => _controller.stream;

  Future<void> connect(List<String> symbols) async {
    _symbols = symbols
        .where((symbol) => symbol.trim().isNotEmpty)
        .toList(growable: false);
    _manualClose = false;
    _reconnectAttempts = 0;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _open(isReconnect: false);
  }

  Future<void> _open({required bool isReconnect}) async {
    _heartbeatTimer?.cancel();
    await _closeChannel();
    _emit(
      MarketSocketEvent(
        status: isReconnect
            ? MarketSocketStatus.reconnecting
            : MarketSocketStatus.connecting,
      ),
    );

    try {
      _channel = WebSocketChannel.connect(_socketUri);
      await _channel!.ready.timeout(const Duration(seconds: 12));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _emit(
            MarketSocketEvent(
              status: MarketSocketStatus.disconnected,
              message: error.toString(),
            ),
          );
          _scheduleReconnect();
        },
        onDone: () {
          _emit(
            const MarketSocketEvent(
              status: MarketSocketStatus.disconnected,
              message: 'Live market stream disconnected.',
            ),
          );
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _emit(const MarketSocketEvent(status: MarketSocketStatus.connected));
      _subscribe();
      _startHeartbeat();
    } catch (error) {
      await _closeChannel();
      _emit(
        MarketSocketEvent(
          status: MarketSocketStatus.disconnected,
          message: error.toString(),
        ),
      );
      _scheduleReconnect();
    }
  }

  void _subscribe() {
    if (_symbols.isEmpty) return;
    _send(<String, dynamic>{
      'action': 'subscribe',
      'type': 'freefeed',
      'symbols': _symbols,
    });
  }

  void _handleMessage(dynamic message) {
    final payload = _decodeMessage(message);
    if (payload == null) return;

    if (payload.isEmpty || _isJsonPayload(payload) || !payload.contains('|')) {
      return;
    }

    try {
      final tick = MarketTick.fromSocketPayload(payload);
      _emit(
        MarketSocketEvent(status: MarketSocketStatus.connected, tick: tick),
      );
    } catch (_) {
      _emit(
        const MarketSocketEvent(
          status: MarketSocketStatus.connected,
          message: 'Skipped malformed live update.',
        ),
      );
    }
  }

  String? _decodeMessage(dynamic message) {
    if (message is String) return message.trim();

    if (message is List<int>) {
      try {
        return utf8.decode(message).trim();
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  bool _isJsonPayload(String payload) {
    return payload.startsWith('{') || payload.startsWith('[');
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _send(<String, dynamic>{'action': 'heartbeat'});
    });
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manualClose) return;

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _emit(
        const MarketSocketEvent(
          status: MarketSocketStatus.failed,
          message: 'Unable to reconnect to live market stream.',
        ),
      );
      return;
    }

    _reconnectAttempts += 1;
    final delaySeconds = _reconnectAttempts * 2;
    _emit(
      const MarketSocketEvent(
        status: MarketSocketStatus.reconnecting,
        message: 'Reconnecting to live market stream...',
      ),
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _open(isReconnect: true);
    });
  }

  void _emit(MarketSocketEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Future<void> dispose() async {
    _manualClose = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _closeChannel();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  Future<void> _closeChannel() async {
    final channel = _channel;
    _channel = null;

    await _subscription?.cancel();
    _subscription = null;
    if (channel == null) return;

    try {
      await channel.sink.close().timeout(const Duration(seconds: 2));
    } catch (_) {}
  }
}

class MarketTick extends Equatable {
  final String name;
  final double currentValue;
  final double high;
  final double low;
  final double open;
  final double close;
  final double changePercent;

  const MarketTick({
    required this.name,
    required this.currentValue,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
    required this.changePercent,
  });

  factory MarketTick.fromSocketPayload(String payload) {
    final parts = payload.split('|');
    if (parts.length < 8) {
      throw const FormatException('Invalid market tick payload');
    }

    return MarketTick(
      name: parts[1].trim(),
      currentValue: _toDouble(parts[2]),
      high: _toDouble(parts[3]),
      low: _toDouble(parts[4]),
      open: _toDouble(parts[5]),
      close: _toDouble(parts[6]),
      changePercent: _toDouble(parts[7]),
    );
  }

  @override
  List<Object> get props => [
    name,
    currentValue,
    high,
    low,
    open,
    close,
    changePercent,
  ];
}

class MarketSocketEvent extends Equatable {
  final MarketSocketStatus status;
  final MarketTick? tick;
  final String? message;

  const MarketSocketEvent({required this.status, this.tick, this.message});

  @override
  List<Object?> get props => [status, tick, message];
}

enum MarketSocketStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
}
