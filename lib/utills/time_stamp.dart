import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formattedTimestamp(Timestamp timestamp) {
  final formatter = DateFormat('dd/MM/y hh:mm a'); // Customize format as needed
  return formatter.format(timestamp.toDate().toLocal());
}

String formattedDateTime(DateTime dateTime) {
  dateTime = DateTime.now();
  String formattedDate = DateFormat('yyyy/MM/dd  kk:mm').format(dateTime);
  return formattedDate;
}