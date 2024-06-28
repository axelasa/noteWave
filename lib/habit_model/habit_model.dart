class HabitModel{
  String name;
  bool isCompleted;
  DateTime date;

  HabitModel({required this.name,required this.isCompleted,required this.date});

  bool get completed => isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      name: json['name'],
      isCompleted: false,
      date: DateTime.parse(json['date']),

    );
  }
}