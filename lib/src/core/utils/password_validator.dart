enum PasswordStrength {
  none,
  weak,
  medium,
  strong
}

class PasswordValidator {
  static PasswordStrength getStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    bool hasLength = password.length >= 8;
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSymbol = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);

    int score = 0;
    if (hasLength) score++;
    if (hasLetter) score++;
    if (hasNumber) score++;
    if (hasSymbol) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score == 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  static bool isValid(String password) {
    if (password.isEmpty) return false;
    bool hasLength = password.length >= 8;
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSymbol = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);
    
    return hasLength && hasLetter && hasNumber && hasSymbol;
  }
}
