class AppValidator {


    String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    // Add more username validation logic if needed
    return null;
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    // Add more email validation logic if needed
    return null;
  }
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Please enter a valid phone number';
    }
    // Add more phone number validation logic if needed
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Please enter a valid password';
    }
    // Add more password validation logic if needed
    return null;
  }
  String? isEmptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill details';
    }
    return null;
  }



}