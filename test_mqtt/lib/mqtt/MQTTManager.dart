import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:test_mqtt/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  // MqttClient? _client;
  final String _clientId ;
  // final String _port;
  final String _host;
  final String _topic;
  final String _username;
  final String _password;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
        required String topic,
        // required String port,
        required String username,
        required String password,
        required String clientId,
        required MQTTAppState state})
      : _clientId = clientId,
        _host = host,
        // _port = port,
        _topic = topic,
        _username = username,
        _password = password,
        _currentState = state;

  Future<void> initializeMQTTClient() async  {
    _client = MqttServerClient.withPort(_host, _clientId, 1883);
    // _client!.keepAlivePeriod = 20;
    //
    // _client!.secure = false;
    _client!.logging(on: true);
    // _client!.setProtocolV311();

    _client!.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    // _client!.onBadCertificate = (dynamic a) => true;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .keepAliveFor(60)
        // .withClientIdentifier(_identifier)
        .withWillTopic(
        'willtopic') // If you set this you must set a will message
        .withWillMessage('Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
    // try {
    //   await _client!.connect();//
    //   print('Connection successful');
    // } on Exception catch (e) {
    //   print('Connection failed - $e');
    //   _client!.disconnect();
    // }
  }

  // Connect to the host
  // ignore: avoid_void_async
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
    builder.addString(message);
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
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}