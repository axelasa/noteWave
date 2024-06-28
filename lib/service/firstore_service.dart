import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_wave/habit_model/habit_model.dart';

import '../components/datetime/date_time.dart';

class FireStoreService{
  final notes = FirebaseFirestore.instance.collection('notes');
  final tasks = FirebaseFirestore.instance.collection('tasks');
  final habits = FirebaseFirestore.instance.collection('TrackedHabits');

  //create note

  Future<void> addNote(String title, String note){
  return notes.add({
    'title':title,
    'note':note,
    'timestamp':Timestamp.now(),
  });
}

//create Task

  Future<void>addTask(String task, bool isCompleted,String due) {

    return tasks.add({
      'task':task,
      'due':due,
      'isCompleted':isCompleted,
      'timestamp':Timestamp.now(),
    });
  }

  //create habit

  Future<void>addHabit (String habit,bool isCompleted) {

    return habits.add({
      "habit":habit,
      'isCompleted':isCompleted,
      'timestamp':Timestamp.now(),
    });
  }

//Read Notes

Stream<QuerySnapshot>getNotesStream() {
  final notesStream = notes.orderBy('timestamp',descending:true).snapshots();
  return notesStream;
}

//Read Tasks

  Stream<QuerySnapshot>getTasksStream() {
    final taskStream = tasks.orderBy('timestamp',descending: true).snapshots();
    return taskStream;
  }

  // //Read Habits
  Stream<QuerySnapshot>getHabits() {
    final habitStream = habits.orderBy('timestamp',descending: true).snapshots();
    return habitStream;
  }

//Update Notes
  Future <void> updateNote (String docId, String newTitle, String newNote){
    return notes.doc(docId).update({
      'title':newTitle,
      'note':newNote,
      'timestamp':Timestamp.now(),
    });
  }

  //Update Tasks
  Future<void>updateTask(String docId, String newHabit, bool isCompleted){
    return tasks.doc(docId).update({
      'habit':newHabit,
      'isCompleted':isCompleted,
      'timestamp':Timestamp.now(),
    });
  }



  //completeTask
  Future<void> completeTask(String docId, bool value) {
    return tasks.doc(docId).update({
      'isCompleted': value,
      'timestamp': Timestamp.now(),
    });
  }

  // //completedHabit
  // Future<void> completeHabit(String docId, bool value) {
  //   return habit.doc(docId).update({
  //     'isCompleted': value,
  //     'timestamp': Timestamp.now(),
  //   });
  // }
//delete Note

Future<void>deleteNote(String docId){
  return notes.doc(docId).delete();
 }

 //delete Task
  Future<void>deleteTask(String docId){
    return tasks.doc(docId).delete();
  }

  //delete habit
Future<void>deleteHabit(String docId){
    return habits.doc(docId).delete();
}

//habit code

  // Create habit
  Future<void> addHabits(List<HabitModel> habitsList) async {
    Map<String, List<HabitModel>> habitsByDate = {};
    for (var habit in habitsList) {
      String dateKey = habit.date.toIso8601String().split('T')[0]; // YYYY-MM-DD
      if (habitsByDate[dateKey] == null) {
        habitsByDate[dateKey] = [];
      }
      habitsByDate[dateKey]!.add(habit);
    }

    for (var entry in habitsByDate.entries) {
      await habits.doc(entry.key).set({
        'habits': entry.value.map((habit) => habit.toJson()).toList(),
      });
    }
  }


  // Read habits for a specific date
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async {
    String dateKey = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    DocumentSnapshot doc = await habits.doc(dateKey).get();

    if (doc.exists) {
      List<dynamic> habitData = doc['habits'];
      return habitData.map((json) => HabitModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  //update specific habit
  Future<void> updateHabit(DateTime date, HabitModel updatedHabit) async {
    String dateKey = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    DocumentSnapshot doc = await habits.doc(dateKey).get();

    if (doc.exists) {
      List<dynamic> habitData = doc['habits'];
      List<HabitModel> habitList = habitData.map((json) => HabitModel.fromJson(json)).toList();

      // Find and update the specific habit
      for (int i = 0; i < habitList.length; i++) {
        if (habitList[i].name == updatedHabit.name) {
          habitList[i] = updatedHabit;
          break;
        }
      }

      // Update the document
      await habits.doc(dateKey).update({
        'habits': habitList.map((habit) => habit.toJson()).toList(),
      });
    } else {
      throw Exception('No habits found for the given date.');
    }
  }

  // void calculateHabitPercentages(){
  //   int countCompleted = 0;
  //   for (int i = 0; i < habitList.length; i++) {
  //     if (habitList[i][1] == true) {
  //       countCompleted++;
  //     }
  //   }
  //
  //   String percent = habitList.isEmpty
  //       ? '0.0'
  //       : (countCompleted / habitList.length).toStringAsFixed(1);
  //
  //   // key: "PERCENTAGE_SUMMARY_yyyymmdd"
  //   // value: string of 1dp number between 0.0-1.0 inclusive
  //   _storage.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  // }
  //
  // void loadHeatMap() {
  //   DateTime startDate = createDateTimeObject(_storage.get("START_DATE"));
  //
  //   // count the number of days to load
  //   int daysInBetween = DateTime.now().difference(startDate).inDays;
  //
  //   // go from start date to today and add each percentage to the dataset
  //   // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
  //   for (int i = 0; i < daysInBetween + 1; i++) {
  //     String yyyymmdd = convertDateTimeToString(
  //       startDate.add(Duration(days: i)),
  //     );
  //
  //     double strengthAsPercent = double.parse(
  //       _storage.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
  //     );
  //
  //     // split the datetime up like below so it doesn't worry about hours/mins/secs etc.
  //
  //     // year
  //     int year = startDate.add(Duration(days: i)).year;
  //
  //     // month
  //     int month = startDate.add(Duration(days: i)).month;
  //
  //     // day
  //     int day = startDate.add(Duration(days: i)).day;
  //
  //     final percentForEachDay = <DateTime, int>{
  //       DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
  //     };
  //
  //     heatMapDataSet.addEntries(percentForEachDay.entries);
  //     debugPrint('$heatMapDataSet');
  //   }
  // }


  Future<void> calculateHabitPercentages(DateTime date) async {
    String dateKey = date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    DocumentSnapshot doc = await habits.doc(dateKey).get();

    if (doc.exists) {
      List<dynamic> habitData = doc['habits'];
      List<HabitModel> habitList = habitData.map((json) => HabitModel.fromJson(json)).toList();

      int countCompleted = habitList.where((habit) => habit.isCompleted).length;
      String percent = habitList.isEmpty ? '0.0' : (countCompleted / habitList.length).toStringAsFixed(1);

      await habits.doc(dateKey).update({
        'percentage': percent,
      });
    }
  }

  Future<Map<DateTime, int>> loadHeatMap() async {
    QuerySnapshot querySnapshot = await habits.get();
    Map<DateTime, int> heatMapDataSet = {};

    for (var doc in querySnapshot.docs) {
      DateTime date = DateTime.parse(doc.id); // assuming doc.id is in YYYY-MM-DD format
      double strengthAsPercent = double.parse(doc['percentage'] ?? '0.0');
      heatMapDataSet[date] = (10 * strengthAsPercent).toInt();
    }

    return heatMapDataSet;
  }

  //firestore Service for Habit
}



