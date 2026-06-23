import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/stocks_model.dart';
import '../../domain/entities/stocks_entity.dart';

class StocksSocketService {
  static final Uri _socketUri = Uri.parse('wss://streamer.ysil.in/');
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
    _symbols = symbols;
    _manualClose = false;
    _reconnectAttempts = 0;
    await _open(isReconnect: false);
  }

  Future<void> reconnect() async {
    _manualClose = false;
    _reconnectAttempts = 0;
    await _open(isReconnect: true);
  }

  Future<void> _open({required bool isReconnect}) async {
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
    if (_symbols.isEmpty) return;
    _send(<String, dynamic>{
      'action': 'subscribe',
      'type': 'freefeed',
      'symbols': _symbols,
    });
  }

  void _handleMessage(dynamic message) {
    if (message is! String || message.trim().isEmpty) return;
    final payload = message.trim();

    if (!payload.contains('|')) return;

    try {
      final tick = StockTickModel.fromSocketPayload(payload);
      _emit(
        StockSocketEventEntity(status: StockSocketStatus.connected, tick: tick),
      );
    } catch (error) {
      _emit(
        StockSocketEventEntity(
          status: StockSocketStatus.connected,
          message: 'Skipped malformed live update.',
        ),
      );
    }
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
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
}
