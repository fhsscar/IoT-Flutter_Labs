// lib/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:my_project/core/di.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/presentation/widgets/custom_text_field.dart';
import 'package:my_project/presentation/widgets/primary_button.dart';
import 'package:my_project/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _repo = getIt<UserRepository>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = User(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // Зберігаємо користувача в SharedPreferences
      await _repo.register(user);

      // Перевіряємо, чи віджет ще живий
      if (!mounted) return;

      // Показуємо успіх
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Реєстрація успішна! Тепер увійдіть'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Перехід на логін — ЧИСТО І НАДІЙНО
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Якщо щось пішло не так — показуємо помилку
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка реєстрації: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Завжди знімаємо лоадер
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                hint: "Ім'я",
                icon: Icons.person,
                controller: _nameCtrl,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Email',
                icon: Icons.email,
                controller: _emailCtrl,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Пароль',
                icon: Icons.lock,
                obscure: true,
                controller: _passCtrl,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 30),
              // ignore: prefer_if_elements_to_conditional_expressions
              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: 'Зареєструватись',
                      onPressed: _register,
                    ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Вже є акаунт? Увійти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
