// lib/core/mqtt_service.dart

import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  MqttServerClient? client;
  final _imageController = StreamController<String>.broadcast();
  String? _currentTopic;

  Stream<String> get imageStream => _imageController.stream;
  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;
  String? get topic => _currentTopic;

  Future<void> connect() async {
    if (isConnected) return;

    client?.disconnect();

    final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
    _currentTopic = 'camera/frontdoor';

    client = MqttServerClient('localhost', clientId);
    client!.port = 8883;
    client!.keepAlivePeriod = 60;
    client!.logging(on: false);

    final message = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    client!.connectionMessage = message;

    try {
      await client!.connect();

      if (client!.connectionStatus?.state != MqttConnectionState.connected) {
        throw Exception('Помилка зєднання');
      }

      client!.subscribe(_currentTopic!, MqttQos.atLeastOnce);

      client!.updates!.listen((messages) {
        final message = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          message.payload.message,
        );

        _processImage(payload);
      });
    } on SocketException catch (e) {
      print('❌ Socket помилка: $e');
      client?.disconnect();
      throw Exception('Помилка зєднання: не вдалося підключитись до брокера');
    } catch (e) {
      print('❌ Інша помилка: $e');
      client?.disconnect();
      rethrow;
    }
  }

  void _processImage(String payload) {
    try {
      print('📨 Отримано: ${payload.length} символів');

      var base64 = payload.trim();

      if (base64.startsWith('data:image')) {
        print('✅ Data URI виявлено');
        _imageController.add(base64);
        return;
      }

      if (base64.contains(',')) {
        base64 = base64.split(',').last;
      }

      base64 = base64.replaceAll(RegExp(r'\s+'), '');

      while (base64.length % 4 != 0) {
        base64 += '=';
      }

      print('✅ Обробка завершена: ${base64.length} символів');
      _imageController.add('data:image/jpeg;base64,$base64');
    } catch (e) {
      print('❌ Помилка обробки: $e');
    }
  }

  void disconnect() {
    client?.disconnect();
  }
}
