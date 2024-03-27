import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

typedef WifiListener = Function(bool enabled);

class WifiService {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  static List<ConnectivityResult>? _connectivityResult;

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged;

  WifiService({WifiListener? listener}) {
    if (_subscription != null) _subscription!.cancel();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _connectivityResult = results;
      // Got a new connectivity status!
      if (listener != null) {
        listener(isConnected(results));
      }
    });
  }

  static Future<bool> isConnectivity() async {
    var connectivityResult =
        _connectivityResult ?? await (Connectivity().checkConnectivity());
    return isConnected(connectivityResult);
  }

  static Future<bool> isDisconnectWhenCallApi() async {
    var connectivityResult =
        _connectivityResult ?? await Connectivity().checkConnectivity();
    bool status = isConnected(connectivityResult);
    return !status;
  }

  static Future<bool> isDisconnect() async {
    var connectivityResult =
        _connectivityResult ?? await Connectivity().checkConnectivity();
    return !isConnected(connectivityResult);
  }

  close() {
    _subscription?.cancel();
  }

  static bool isConnected(List<ConnectivityResult> connectivityResult) {
    bool value = false;
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      value = true;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      value = false;
    }
    return value;
  }
}
