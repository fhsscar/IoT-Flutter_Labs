import 'package:flutter/material.dart';

class CameraCard extends StatelessWidget {
  final String name;
  final String status;
  final int alerts;
  final DateTime? lastMotion;
  final VoidCallback onTap;

  const CameraCard({
    required this.name,
    required this.status,
    required this.alerts,
    required this.onTap,
    super.key,
    this.lastMotion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(status == 'Онлайн' ? Icons.videocam : Icons.videocam_off),
        title: Text(name),
        subtitle: Text(status),
        trailing: alerts > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$alerts',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
