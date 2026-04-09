class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Некорректный формат email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }
    if (value != password) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  static String? notEmpty(String? value, {String field = 'Поле'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field обязательно для заполнения';
    }
    return null;
  }

  static String? habitTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите название привычки';
    }
    if (value.trim().length < 2) {
      return 'Название слишком короткое';
    }
    if (value.trim().length > 50) {
      return 'Название слишком длинное (макс. 50 символов)';
    }
    return null;
  }
}
