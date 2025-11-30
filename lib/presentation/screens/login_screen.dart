// lib/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:my_project/core/di.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/presentation/widgets/custom_text_field.dart';
import 'package:my_project/presentation/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _repo = getIt<UserRepository>();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Слухаємо зміни в полях — щоб кнопка активувалась одразу
    _emailCtrl.addListener(_updateButton);
    _passCtrl.addListener(_updateButton);
  }

  void _updateButton() {
    setState(() {}); // Просто перемальовуємо віджет (оновлюємо стан кнопки)
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_updateButton);
    _passCtrl.removeListener(_updateButton);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _error = null);

    final user = await _repo.login(_emailCtrl.text, _passCtrl.text);
    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _error = 'Невірний email або пароль');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              hint: 'Email',
              icon: Icons.email,
              controller: _emailCtrl,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Пароль',
              icon: Icons.lock,
              obscure: true,
              controller: _passCtrl,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Увійти',
              onPressed: _emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty
                  ? _login
                  : null, // тепер кнопка активується одразу при введенні
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Немає акаунту? Зареєструйтесь'),
            ),
          ],
        ),
      ),
    );
  }
}
