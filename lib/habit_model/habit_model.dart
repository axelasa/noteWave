import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  String name;
  bool isCompleted;
  DateTime date;

  HabitModel({required this.name, required this.isCompleted, required this.date});

  bool get completed => isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'date': Timestamp.now(),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      name: json['name'],
      isCompleted: json['isCompleted'],
      date: DateTime.parse(json['date']),
    );
  }
}