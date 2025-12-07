// lib/presentation/screens/camera_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_project/core/mqtt_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _mqtt = MQTTService();
  String? _currentImage;
  bool _isConnecting = false;
  // ignore: strict_raw_type
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _mqtt.imageStream.listen(
      (image) {
        print('🖼️ Нове зображення отримано');
        if (mounted) {
          setState(() => _currentImage = image);
        }
      },
      // ignore: inference_failure_on_untyped_parameter
      onError: (error) {
        print('❌ Помилка stream: $error');
      },
    );
    _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;

    setState(() => _isConnecting = true);

    try {
      await _mqtt.connect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Підключено!\nТопік: ${_mqtt.topic}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Камера - Вхідні двері'),
        backgroundColor: _mqtt.isConnected ? Colors.green : Colors.red,
        actions: [
          if (_isConnecting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(_mqtt.isConnected ? Icons.check_circle : Icons.error),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: !_mqtt.isConnected
          ? FloatingActionButton(
              onPressed: _connect,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Підключення до MQTT...'),
          ],
        ),
      );
    }

    if (_currentImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Очікування зображень...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_mqtt.isConnected) ...[
              const SizedBox(height: 16),
              Text(
                'Топік: ${_mqtt.topic}',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ],
          ],
        ),
      );
    }

    return InteractiveViewer(
      child: Center(
        child: Image.memory(
          base64Decode(_currentImage!.split(',').last),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.error, size: 100, color: Colors.red),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _mqtt.disconnect();
    super.dispose();
  }
}
