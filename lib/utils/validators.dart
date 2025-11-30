class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Введіть імʼя';
    if (RegExp(r'\d').hasMatch(value)) return 'Імʼя не може містити цифри';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введіть email';
    if (!value.contains('@') || !value.contains('.')) return 'Невірний email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пароль';
    if (value.length < 4) return 'Пароль занадто короткий';
    return null;
  }
}
