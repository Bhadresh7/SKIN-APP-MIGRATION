import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:skin_app_migration/core/constants/app_status.dart';

class InternetProvider extends ChangeNotifier {
  final InternetConnectionChecker _checker =
  InternetConnectionChecker.createInstance();

  StreamSubscription<InternetConnectionStatus>? _subscription;

  String _connectionStatus = "Unknown";
  bool _isLoading = false;

  String get connectionStatus => _connectionStatus;

  bool get isLoading => _isLoading;

  /// Callback to notify when reconnected
  void Function()? onReconnected;

  InternetProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription = _checker.onStatusChange.listen(_handleStatusChange);
  }

  void _handleStatusChange(InternetConnectionStatus status) {
    final previousStatus = _connectionStatus;
    _updateStatus(status);

    final nowConnected = _connectionStatus == AppStatus.kConnected;
    final wasNotConnected = previousStatus != AppStatus.kConnected;

    if (nowConnected && wasNotConnected) {
      onReconnected?.call();
    }
  }

  Future<void> checkConnectivity() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    final status = await _checker.connectionStatus;
    _handleStatusChange(status);

    _isLoading = false;
    notifyListeners();
  }

  void _updateStatus(InternetConnectionStatus status) {
    switch (status) {
      case InternetConnectionStatus.connected:
        _connectionStatus = AppStatus.kConnected;
        break;
      case InternetConnectionStatus.disconnected:
        _connectionStatus = AppStatus.kDisconnected;
        break;
      case InternetConnectionStatus.slow:
        _connectionStatus = AppStatus.kSlow;
        break;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
