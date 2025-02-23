class FormValidators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Email address is required";
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return "Please enter a valid email";
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password is required";
    }
    
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }
} 