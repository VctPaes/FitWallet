class Email {
  final String value;

  Email(String email) : value = _validate(email);

  static String _validate(String email) {
    if (email.isEmpty) {
      throw ArgumentError('Email não pode ser vazio');
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      throw FormatException('Formato de email inválido: $email');
    }
    return email;
  }

  @override
  String toString() => 'Email(value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Email && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}