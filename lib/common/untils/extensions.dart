import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get timeReadable => DateFormat().add_Hm().format(this);
  String get dateReadable => DateFormat().add_yMMMEd().format(this);
  String get dateTimeReadable => '$dateReadable,$timeReadable';
  static String showDateTime(String? date) {
    if(date == null) return 'Date unavailable';
    try {
      DateTime dateTime = DateTime.parse(date);
      return dateTime.dateReadable;
    } catch (e, trace) {
      debugPrint(trace.toString());
      return e.toString();
    }
  }
}