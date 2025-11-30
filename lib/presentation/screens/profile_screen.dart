import 'package:flutter/material.dart';
import 'package:my_project/core/di.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/presentation/widgets/custom_text_field.dart';
import 'package:my_project/presentation/widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = getIt<UserRepository>();
  User? _user;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _repo.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameCtrl = TextEditingController(text: user.name);
        _emailCtrl = TextEditingController(text: user.email);
      });
    }
  }

  void _save() async {
    if (_user == null) return;

    final updated = User(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _user!.password,
    );

    await _repo.updateUser(updated);

    if (!mounted) return; // ДОДАЙ ЦЕ!

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Збережено!')));
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Імʼя',
              icon: Icons.person,
              controller: _nameCtrl,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Email',
              icon: Icons.email,
              controller: _emailCtrl,
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Зберегти', onPressed: _save),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Вийти', onPressed: _logout),
          ],
        ),
      ),
    );
  }
}
