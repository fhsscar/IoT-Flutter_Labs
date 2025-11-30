// lib/presentation/screens/home_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_project/domain/models/camera.dart';
import 'package:my_project/presentation/widgets/camera_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Camera> cameras;

  @override
  void initState() {
    super.initState();
    _generateRandomAlerts();
  }

  void _generateRandomAlerts() {
    final random = Random();
    final now = DateTime.now();

    cameras = [
      Camera(name: 'Вхідні двері', isOnline: true),
      Camera(name: 'Гараж', isOnline: false),
      Camera(name: 'Двір', isOnline: true),
    ];

    for (var cam in cameras) {
      if (cam.isOnline) {
        final eventCount = random.nextInt(6);
        for (int i = 0; i < eventCount; i++) {
          final minutesAgo = random.nextInt(1440);
          final eventTime = now.subtract(Duration(minutes: minutesAgo));
          cam.motionHistory.add(MotionEvent(timestamp: eventTime));
        }
        cam.alerts = cam.motionHistory.length;
        if (cam.motionHistory.isNotEmpty) {
          cam.lastMotion = cam.motionHistory.last.timestamp;
        }
      }
    }
    setState(() {});
  }

  void _resetAlerts(String name) {
    setState(() {
      final cam = cameras.firstWhere((c) => c.name == name);
      cam.clearAlerts();
    });
  }

  Widget _buildCameraList() {
    final width = MediaQuery.of(context).size.width;

    final cameraWidgets = cameras.map((cam) {
      return CameraCard(
        name: cam.name,
        status: cam.isOnline ? 'Онлайн' : 'Офлайн',
        alerts: cam.alerts,
        lastMotion: cam.lastMotion,
        onTap: () {
          _resetAlerts(cam.name);
          // ПРАВИЛЬНА НАВІГАЦІЯ — ось це головне!
          Navigator.pushNamed(
            context,
            '/camera',
            arguments: cam, // передаємо об’єкт камери
          );
        },
      );
    }).toList();

    if (width > 600) {
      return GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3,
        children: cameraWidgets,
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: cameraWidgets,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Камери'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _buildCameraList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateRandomAlerts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
