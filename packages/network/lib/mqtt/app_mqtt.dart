import 'package:_iwu_pack/_iwu_pack.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:_iwu_pack_network/options.dart';

enum MQTTConnectionState { connecting, connected, disconnected }

class AppMQTT {
  MqttClient? _client;
  final String _identifier;
  final bool _allowPrintLog;
  Function(String topic, String payload)? onMQTTMessage;
  Function(bool isReconnect)? onMQTTConnected;
  Function()? onMQTTDisconnected;

  // Constructor
  // ignore: sort_constructors_first
  AppMQTT({
    bool allowPrintLog = false,
    required String identifier,
  })  : _identifier = identifier,
        _allowPrintLog = allowPrintLog;

  void initializeMQTTClient([bool logging = kDebugMode]) {
    String host = appMqttUrl != null ? 'wss://$appMqttUrl/mqtt' : '';
    int port = appMqttPort ?? 80;

    _client = MqttServerClient(host, _identifier)
      ..setProtocolV311()
      ..autoReconnect = true
      ..port = port
      ..keepAlivePeriod = 200
      ..useWebSocket = true
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      ..logging(on: logging)

      /// Add the successful connection callback
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected
      ..onAutoReconnected = onReConnected
      ..onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        // .withWillTopic(
        //     'willtopic') // If you set this you must set a will message
        // .withWillMessage('My Will message')
        // .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    if (_allowPrintLog) appDebugPrint('MQTT::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect([String? username, String? password]) async {
    assert(_client != null);
    try {
      if (_allowPrintLog) {
        appDebugPrint('MQTT::Mosquitto start client connecting....');
      }

      await _client!.connect(username, password);
    } on Exception catch (e) {
      if (_allowPrintLog) appDebugPrint('MQTT::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    if (_allowPrintLog) appDebugPrint('MQTT::Disconnected');
    _client!.disconnect();
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    if (_allowPrintLog) {
      appDebugPrint('MQTT::Subscription confirmed for topic $topic');
    }
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    if (_allowPrintLog) {
      appDebugPrint(
          'MQTT::OnDisconnected client callback - Client disconnection');
    }
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      if (_allowPrintLog) {
        appDebugPrint(
            'MQTT::OnDisconnected callback is solicited, this is correct');
      }
    }
    if (onMQTTDisconnected != null) onMQTTDisconnected!();
  }

  void subscribeTo(String channel) {
    _client!.subscribe(channel, MqttQos.atLeastOnce);
  }

  void unsubscribeTo(String channel) {
    _client!.unsubscribe(channel);
  }

  /// The successful connect callback
  void onConnected() {
    if (_allowPrintLog) appDebugPrint('MQTT::Mosquitto client connected....');
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (_allowPrintLog) {
        appDebugPrint(
            'MQTT::Change notification:: topic is <${c[0].topic}>, payload is <-- $payload -->');
      }
      if (onMQTTMessage != null) onMQTTMessage!(c[0].topic, payload);
      // AppUtils.toast(payload);
    });
    if (onMQTTConnected != null) onMQTTConnected!(false);
    if (_allowPrintLog) {
      appDebugPrint(
          'MQTT::OnConnected client callback - Client connection was sucessful');
    }
  }

  void onReConnected() {
    if (_allowPrintLog) appDebugPrint('MQTT::Mosquitto client reconnected....');
    if (onMQTTConnected != null) onMQTTConnected!(true);
  }
}
