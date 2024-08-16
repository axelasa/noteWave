extension EmailValidator on String {
  bool get isValidEmail => RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(this);
}