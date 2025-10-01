String? nameValidator(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return "$fieldName is required";
  }

  final parts = value.trim().split(RegExp(r'\s+'));

  if (parts.length < 2) {
    return "$fieldName must contain at least 2 words";
  }

  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Email is required";
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return "Enter a valid email";
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }

  if (value.length < 6) {
    return "Password should have more than 6 characters";
  }

  return null;
}
