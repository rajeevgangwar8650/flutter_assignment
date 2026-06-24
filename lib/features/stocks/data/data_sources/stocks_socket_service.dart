import 'dart:async';
import 'dart:convert';
import 'package:flutter_assignment/core/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/stocks_model.dart';
import '../../domain/entities/stocks_entity.dart';

class StocksSocketService {
  static final Uri _socketUri = Uri.parse(ApiConstants.socketUrl);
  static const int _maxReconnectAttempts = 5;

  final StreamController<StockSocketEventEntity> _controller =
      StreamController<StockSocketEventEntity>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  List<String> _symbols = const [];
  int _reconnectAttempts = 0;
  bool _manualClose = false;

  Stream<StockSocketEventEntity> get stream => _controller.stream;

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
      StockSocketEventEntity(
        status: isReconnect
            ? StockSocketStatus.reconnecting
            : StockSocketStatus.connecting,
      ),
    );

    try {
      _channel = WebSocketChannel.connect(_socketUri);
      await _channel!.ready.timeout(const Duration(seconds: 12));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _emit(
            StockSocketEventEntity(
              status: StockSocketStatus.disconnected,
              message: error.toString(),
            ),
          );
          _scheduleReconnect();
        },
        onDone: () {
          _emit(
            const StockSocketEventEntity(
              status: StockSocketStatus.disconnected,
              message: 'Live market stream disconnected.',
            ),
          );
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _emit(const StockSocketEventEntity(status: StockSocketStatus.connected));
      _subscribe();
      _startHeartbeat();
    } catch (error) {
      await _closeChannel();
      _emit(
        StockSocketEventEntity(
          status: StockSocketStatus.disconnected,
          message: error.toString(),
        ),
      );
      _scheduleReconnect();
    }
  }

  void _subscribe() {
    if (_symbols.isEmpty) {
      return;
    }
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
      final tick = StockTickModel.fromSocketPayload(payload);
      _emit(
        StockSocketEventEntity(status: StockSocketStatus.connected, tick: tick),
      );
    } catch (_) {
      _emit(
        StockSocketEventEntity(
          status: StockSocketStatus.connected,
          message: 'Skipped malformed live update.',
        ),
      );
    }
  }

  String? _decodeMessage(dynamic message) {
    if (message is String) {
      return message.trim();
    }

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
      final data = jsonEncode(payload);
      _channel?.sink.add(data);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manualClose) {
      return;
    }
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _emit(
        const StockSocketEventEntity(
          status: StockSocketStatus.failed,
          message: 'Unable to reconnect to live market stream.',
        ),
      );
      return;
    }

    _reconnectAttempts += 1;
    final delaySeconds = _reconnectAttempts * 2;
    _emit(
      StockSocketEventEntity(
        status: StockSocketStatus.reconnecting,
        message: 'Reconnecting to live market stream...',
      ),
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _open(isReconnect: true);
    });
  }

  void _emit(StockSocketEventEntity event) {
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
