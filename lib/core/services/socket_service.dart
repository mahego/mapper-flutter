import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _logger = Logger();
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize and connect to Socket.IO server
  void connect({String? token}) {
    if (_socket != null && _isConnected) {
      _logger.i('Socket already connected');
      return;
    }

    try {
      // Extract base URL from API endpoint
      final baseUrl = AppConstants.baseUrl.replaceAll('/api', '');
      
      _logger.i('Connecting to Socket.IO at: $baseUrl');

      final optionBuilder = IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(3000);

      if (token != null) {
        optionBuilder.setAuth({'token': token});
      }

      _socket = IO.io(baseUrl, optionBuilder.build());

      _socket!.onConnect((_) {
        _isConnected = true;
        _logger.i('Socket connected successfully');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        _logger.w('Socket disconnected');
      });

      _socket!.onConnectError((error) {
        _logger.e('Socket connection error: $error');
      });

      _socket!.onError((error) {
        _logger.e('Socket error: $error');
      });

      _socket!.onReconnect((attempt) {
        _logger.i('Socket reconnected on attempt: $attempt');
      });

      _socket!.onReconnectAttempt((attempt) {
        _logger.i('Socket reconnection attempt: $attempt');
      });

      _socket!.onReconnectFailed((_) {
        _logger.e('Socket reconnection failed');
      });
    } catch (e) {
      _logger.e('Error initializing socket: $e');
    }
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    if (_socket != null) {
      _logger.i('Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Emit an event to the server
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      _logger.d('Emitted event: $event with data: $data');
    } else {
      _logger.w('Cannot emit event: Socket not connected');
    }
  }

  /// Listen to a specific event
  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      _logger.d('Listening to event: $event');
    } else {
      _logger.w('Cannot listen to event: Socket not initialized');
    }
  }

  /// Remove listener for a specific event
  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
      _logger.d('Stopped listening to event: $event');
    }
  }

  // === Tracking Events ===

  /// Join a tracking room for a specific request
  void joinTrackingRoom(int requestId) {
    emit('join-tracking-room', {'requestId': requestId});
  }

  /// Leave a tracking room
  void leaveTrackingRoom(int requestId) {
    emit('leave-tracking-room', {'requestId': requestId});
  }

  /// Emit location update (for providers)
  void emitLocationUpdate({
    required int requestId,
    required double latitude,
    required double longitude,
    double? speed,
    double? bearing,
  }) {
    emit('location-update', {
      'requestId': requestId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'bearing': bearing,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Listen to tracking updates
  void onTrackingUpdate(Function(Map<String, dynamic>) callback) {
    on('tracking-update', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Listen to location updates
  void onLocationUpdate(Function(Map<String, dynamic>) callback) {
    on('location-update', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Listen to new requests (for providers)
  void onNewRequest(Function(Map<String, dynamic>) callback) {
    on('new-request', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Listen to new counteroffers (for clients)
  void onNewCounteroffer(Function(Map<String, dynamic>) callback) {
    on('new-counteroffer', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Listen to request accepted events
  void onRequestAccepted(Function(Map<String, dynamic>) callback) {
    on('request-accepted', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Listen to request completed events
  void onRequestCompleted(Function(Map<String, dynamic>) callback) {
    on('request-completed', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  // === Convenience Methods ===

  /// Stop listening to all tracking events
  void removeTrackingListeners() {
    off('tracking-update');
    off('location-update');
    off('new-request');
    off('new-counteroffer');
    off('request-accepted');
    off('request-completed');
  }
}
