class MotionEvent {
  final DateTime timestamp;
  final String description;

  MotionEvent({required this.timestamp, this.description = 'Рух виявлено'});
}

class Camera {
  final String name;
  final bool isOnline;
  int alerts;
  DateTime? lastMotion;
  final List<MotionEvent> motionHistory;

  Camera({
    required this.name,
    required this.isOnline,
    this.alerts = 0,
    this.lastMotion,
    List<MotionEvent>? motionHistory,
  }) : motionHistory = motionHistory ?? [];

  void addMotionEvent() {
    final now = DateTime.now();
    lastMotion = now;
    motionHistory.add(MotionEvent(timestamp: now));
    alerts = motionHistory.length;
  }

  void clearAlerts() {
    alerts = 0;
  }
}
