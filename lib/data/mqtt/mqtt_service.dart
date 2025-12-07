// lib/data/mqtt/mqtt_service.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttServerClient client = MqttServerClient(
    'broker.hivemq.com',
    'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
  );

  static Stream<String>? temperatureStream;

  static Future<bool> connect() async {
    client.port = 1883;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    // ignore: avoid_print
    client.onDisconnected = () => print('MQTT: Відключено');
    // ignore: avoid_print
    client.onConnected = () => print('MQTT: Підключено!');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      // ignore: avoid_print
      print('Підключення до MQTT...');
      await client.connect();
    } catch (e) {
      // ignore: avoid_print
      print('Помилка підключення: $e');
      client.disconnect();
      return false;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      // ignore: avoid_print
      print('Підключено до HiveMQ!');
      client.subscribe('camera/status', MqttQos.atMostOnce);
      client.subscribe('camera/motion', MqttQos.atMostOnce);
      client.subscribe('camera/snapshot', MqttQos.atMostOnce);
      client.subscribe('camera/recording', MqttQos.atMostOnce);

      temperatureStream = client.updates!.map((messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        return MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
      });

      return true;
    }

    return false;
  }

  static void disconnect() {
    client.disconnect();
  }
}
