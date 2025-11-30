// lib/presentation/screens/camera_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:my_project/domain/models/camera.dart';

class CameraDetailScreen extends StatelessWidget {
  const CameraDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Camera camera = ModalRoute.of(context)!.settings.arguments as Camera;

    return Scaffold(
      appBar: AppBar(
        title: Text(camera.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.videocam, size: 100, color: Colors.white54),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'Статус',
                  camera.isOnline ? 'Онлайн' : 'Офлайн',
                  camera.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Останній рух',
                  camera.lastMotion != null
                      ? _formatTime(camera.lastMotion!)
                      : 'Немає',
                  camera.lastMotion != null ? Colors.orange : Colors.grey,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Всього подій',
                  '${camera.motionHistory.length}',
                  Colors.blue,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      Icons.play_circle_outline,
                      'Запис',
                      Colors.red,
                    ),
                    _actionButton(
                      Icons.screen_rotation,
                      'Поворот',
                      Colors.indigo,
                    ),
                    _notificationButton(camera, context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    // ignore: lines_longer_than_80_chars
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        IconButton(onPressed: () {}, icon: Icon(icon, size: 36), color: color),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _notificationButton(Camera camera, BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            IconButton(
              onPressed: () => _showMotionHistory(context, camera),
              icon: const Icon(Icons.notifications_active_outlined, size: 36),
              color: Colors.amber[700],
            ),
            if (camera.motionHistory.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.red,
                  child: Text(
                    camera.motionHistory.length > 99
                        ? '99+'
                        : '${camera.motionHistory.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          'Сповіщення',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  void _showMotionHistory(BuildContext context, Camera camera) {
    // ignore: inference_failure_on_function_invocation
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Історія руху — ${camera.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              Expanded(
                child: camera.motionHistory.isEmpty
                    ? const Center(child: Text('Подій не виявлено'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: camera.motionHistory.length,
                        itemBuilder: (_, i) {
                          final event = camera.motionHistory[i];
                          return ListTile(
                            leading: const Icon(
                              Icons.sensors,
                              color: Colors.orange,
                            ), // ВИПРАВЛЕНО!
                            title: Text(event.description),
                            trailing: Text(_formatTime(event.timestamp)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
