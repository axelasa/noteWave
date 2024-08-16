import 'package:intl/intl.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

String formatDate(String unformattedDate) {
  var currentDate = DateTime.parse(unformattedDate);
  return DateFormat.yMMMEd().format(currentDate);
}

String formatDateandTime(String unformattedDate) {
  var currentDate = DateTime.parse(unformattedDate);
  return DateFormat.yMMMEd().add_jm().format(currentDate);
}

String formatNumber(dynamic amnount) {
  var formatter = NumberFormat('#,###,000.0');
  return formatter.format(amnount);
}

String excapeHtmlFrom(String text) {
  return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
}

bool isNumeric(String str) {
  try {
    double.parse(str);
  } on FormatException {
    return false;
  } finally {
    return true;
  }
}

bool isValidPhoneNumber(String? value) =>
    RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
        .hasMatch(value ?? '');

bool isValidEmail(String? value) => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    .hasMatch(value ?? '');
String capitalize(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();
