import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/live_indices_event.dart';
import '../models/live_index_tick_model.dart';

abstract class IndicesSocketDataSource {
  Stream<LiveIndicesEvent> get stream;

  Future<void> connect(List<String> symbols);

  Future<void> disconnect();

  Future<void> dispose();
}

class IndicesSocketDataSourceImpl implements IndicesSocketDataSource {
  static final Uri _socketUri = Uri.parse(ApiConstants.socketUrl);
  static const Duration _connectTimeout = Duration(seconds: 12);
  static const Duration _heartbeatInterval = Duration(seconds: 25);
  static const int _maxReconnectAttempts = 5;

  final StreamController<LiveIndicesEvent> _controller =
      StreamController<LiveIndicesEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  List<String> _symbols = const [];
  int _reconnectAttempts = 0;
  bool _manualDisconnect = false;
  bool _isDisposed = false;

  @override
  Stream<LiveIndicesEvent> get stream => _controller.stream;

  @override
  Future<void> connect(List<String> symbols) async {
    if (_isDisposed) {
      throw StateError('Indices socket data source is already disposed.');
    }

    _symbols = _validSymbols(symbols);
    _manualDisconnect = false;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();

    if (_symbols.isEmpty) {
      _emit(
        const LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.failed,
          message: 'No live index symbols available.',
        ),
      );
      return;
    }

    await _openSocket(isReconnect: false);
  }

  @override
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    await _closeSocket();
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  Future<void> _openSocket({required bool isReconnect}) async {
    _heartbeatTimer?.cancel();
    await _closeSocket();
    _emit(
      LiveIndicesEvent(
        status: isReconnect
            ? LiveIndicesConnectionStatus.reconnecting
            : LiveIndicesConnectionStatus.connecting,
      ),
    );

    try {
      _channel = WebSocketChannel.connect(_socketUri);
      await _channel!.ready.timeout(_connectTimeout);
      _listenToSocket();
      _reconnectAttempts = 0;
      _emit(
        const LiveIndicesEvent(status: LiveIndicesConnectionStatus.connected),
      );
      _subscribe();
      _startHeartbeat();
    } catch (error) {
      await _closeSocket();
      _emit(
        LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.disconnected,
          message: error.toString(),
        ),
      );
      _scheduleReconnect();
    }
  }

  void _listenToSocket() {
    _subscription = _channel!.stream.listen(
      _handleSocketMessage,
      onError: (Object error) {
        _emit(
          LiveIndicesEvent(
            status: LiveIndicesConnectionStatus.disconnected,
            message: error.toString(),
          ),
        );
        _scheduleReconnect();
      },
      onDone: () {
        if (_manualDisconnect) return;

        _emit(
          const LiveIndicesEvent(
            status: LiveIndicesConnectionStatus.disconnected,
            message: 'Live market stream disconnected.',
          ),
        );
        _scheduleReconnect();
      },
      cancelOnError: true,
    );
  }

  void _subscribe() {
    _send(<String, dynamic>{
      'action': 'subscribe',
      'type': 'freefeed',
      'symbols': _symbols,
    });
  }

  void _handleSocketMessage(dynamic message) {
    final payload = _decodeMessage(message);
    if (payload == null || payload.isEmpty || _isJsonPayload(payload)) return;
    if (!payload.contains('|')) return;

    try {
      final tick = LiveIndexTickModel.fromSocketPayload(payload);
      _emit(
        LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.connected,
          tick: tick,
        ),
      );
    } on FormatException {
      _emit(
        const LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.connected,
          message: 'Skipped malformed live index update.',
        ),
      );
    }
  }

  String? _decodeMessage(dynamic message) {
    if (message is String) return message.trim();

    if (message is List<int>) {
      try {
        return utf8.decode(message).trim();
      } on FormatException {
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
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _send(<String, dynamic>{'action': 'heartbeat'});
    });
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (error) {
      _emit(
        LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.disconnected,
          message: error.toString(),
        ),
      );
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manualDisconnect || _isDisposed) return;

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _emit(
        const LiveIndicesEvent(
          status: LiveIndicesConnectionStatus.failed,
          message: 'Unable to reconnect to live market stream.',
        ),
      );
      return;
    }

    _reconnectAttempts += 1;
    _emit(
      const LiveIndicesEvent(
        status: LiveIndicesConnectionStatus.reconnecting,
        message: 'Reconnecting to live market stream...',
      ),
    );

    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer = Timer(delay, () {
      _openSocket(isReconnect: true);
    });
  }

  Future<void> _closeSocket() async {
    final channel = _channel;
    _channel = null;

    await _subscription?.cancel();
    _subscription = null;
    if (channel == null) return;

    try {
      await channel.sink.close().timeout(const Duration(seconds: 2));
    } catch (_) {
      // Socket close failures are non-actionable during cleanup.
    }
  }

  void _emit(LiveIndicesEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  List<String> _validSymbols(List<String> symbols) {
    return symbols
        .map((symbol) => symbol.trim())
        .where((symbol) => symbol.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
