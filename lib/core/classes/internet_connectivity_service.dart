import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityStreamController =
      StreamController<bool>.broadcast();

  bool _isConnected = true;

  Stream<bool> get onConnectivityChanged =>
      _connectivityStreamController.stream;

  bool get isConnected => _isConnected;

  InternetConnectivityService() {
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((result) async {
      final hasInternet = await _hasInternetConnection(result.first);
      if (_isConnected != hasInternet) {
        _isConnected = hasInternet;
        _connectivityStreamController.add(_isConnected);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = await _hasInternetConnection(result.first);
    _connectivityStreamController.add(_isConnected);
  }

  Future<bool> _hasInternetConnection(ConnectivityResult result) async {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = await _hasInternetConnection(result.first);
    return _isConnected;
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}
