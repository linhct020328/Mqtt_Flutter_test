import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:test_mqtt_ssl_tls/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:test_mqtt_ssl_tls/crypt/crypt.dart';

class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _clientId ;
  final String _host;
  final String _topic;
  final String _username;
  final String _password;

  MQTTManager(
      {
        required MQTTAppState state})
      : _host = '192.168.0.103',
        _clientId = 'mqtt-servo',
        _topic = 'testServo',
        _username = 'linh99',
        _password = '1234567890',
        _currentState = state;

  Future<void> initializeMQTTClient() async  {
    _client = MqttServerClient.withPort(_host, _clientId, 1883);
    // _client = MqttServerClient(_host, _clientId);
    // _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = true;
    _client!.logging(on: true);

    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final context = SecurityContext.defaultContext;

    String clientAuth = await rootBundle.loadString("assets/certs_localhost/mqtt_ca.crt");

    context.setTrustedCertificatesBytes(clientAuth.codeUnits);// context.setClientAuthoritiesBytes(clientAuth.codeUnits);
    String trustedCer = await rootBundle.loadString("assets/certs_localhost/mqtt_client.crt");
    context.useCertificateChainBytes(trustedCer.codeUnits);
    String privateKey = await rootBundle.loadString("assets/certs_localhost/mqtt_client.key");
    context.usePrivateKeyBytes(privateKey.codeUnits);

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withWillTopic('will topic') // If you set this you must set a will message
        .withWillMessage('Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    var msgEncode = crypt.aesEncrypt(message);//encoder
    builder.addString(msgEncode);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}

//   var text = 'open';
//   print('text：${text}');
//
//   var base = crypt.encodeBase64(text);
//   print('base64: ${base}');
//
//   var enStr = crypt.aesEncrypt(text);
//   print('AES encode：${enStr}');
//   var deStr = crypt.aesDecrypt(enStr);
//   print('AES decode：${deStr}');
//
//   var md5 = crypt.encodeMd5(text);
//   print('md5 ：${md5}');