import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'IoT Smart Lamp',
      home: SmartLampPanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SmartLampPanel extends StatefulWidget {
  const SmartLampPanel({super.key});

  @override
  State<SmartLampPanel> createState() => _SmartLampPanelState();
}

class _SmartLampPanelState extends State<SmartLampPanel> {
  double _brightness = 0; // поточна яскравість 0–100
  Timer? _timer;
  final TextEditingController _controller = TextEditingController();

  // Отримати колір лампи залежно від яскравості
  Color _getLampColor() {
    final int intensity = (_brightness * 2.55).toInt();
    return Color.fromARGB(255, intensity, intensity, 0);
  }

  void _changeBrightness(double delta) {
    setState(() {
      _brightness = (_brightness + delta).clamp(0, 100);
      _controller.text = _brightness.toInt().toString();
    });
  }

  void _startContinuousChange(double delta) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _changeBrightness(delta);
    });
  }

  void _stopContinuousChange() {
    _timer?.cancel();
  }

  void _setBrightnessFromInput() {
    final value = double.tryParse(_controller.text.trim());
    if (value != null && value >= 0 && value <= 100) {
      setState(() {
        _brightness = value;
      });
    }
  }

  void _turnOn() {
    setState(() {
      _brightness = 100;
      _controller.text = '100';
    });
  }

  void _turnOff() {
    setState(() {
      _brightness = 0;
      _controller.text = '0';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Smart Lamp')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Візуалізація лампи
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getLampColor(),
                boxShadow: [
                  BoxShadow(
                    color: newMethod(),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _brightness / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: Colors.yellow,
            ),
            const SizedBox(height: 20),
            Text(
              'Яскравість: ${_brightness.toInt()}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Поле вводу
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Введіть яскравість 0–100',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _setBrightnessFromInput(),
            ),
            const SizedBox(height: 20),
            // Кнопки Вкл / Викл
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _turnOn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Вкл'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _turnOff,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Викл'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Кнопки +/- з триманням
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onLongPressStart: (_) => _startContinuousChange(-5),
                  onLongPressEnd: (_) => _stopContinuousChange(),
                  child: ElevatedButton(
                    onPressed: () => _changeBrightness(-5),
                    child: const Icon(Icons.remove),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onLongPressStart: (_) => _startContinuousChange(5),
                  onLongPressEnd: (_) => _stopContinuousChange(),
                  child: ElevatedButton(
                    onPressed: () => _changeBrightness(5),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: deprecated_member_use
  Color newMethod() => _getLampColor().withOpacity(0.6);
}
