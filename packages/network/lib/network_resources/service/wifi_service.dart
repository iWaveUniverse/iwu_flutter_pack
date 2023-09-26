import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

typedef WifiListener = Function(bool enabled);

class WifiService {
  StreamSubscription<ConnectivityResult>? _subscription;

  static ConnectivityResult? _connectivityResult;

  static Stream<ConnectivityResult> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged;

  WifiService({WifiListener? listener}) {
    if (_subscription != null) _subscription!.cancel();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _connectivityResult = result;
      // Got a new connectivity status!
      if (listener != null) {
        listener(result != ConnectivityResult.none);
      }
    });
  }

  static Future<bool> isConnectivity() async {
    var connectivityResult =
        _connectivityResult ?? await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<bool> isDisconnectWhenCallApi() async {
    var connectivityResult =
        _connectivityResult ?? await Connectivity().checkConnectivity();
    bool status = connectivityResult == ConnectivityResult.none;
    return status;
  }

  static Future<bool> isDisconnect() async {
    var connectivityResult =
        _connectivityResult ?? await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  close() {
    _subscription?.cancel();
  }
}
