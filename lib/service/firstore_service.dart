import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_wave/habit_model/habit_model.dart';

import '../components/datetime/date_time.dart';

class FireStoreService {
  final notes = FirebaseFirestore.instance.collection('notes');
  final tasks = FirebaseFirestore.instance.collection('tasks');
  final habits = FirebaseFirestore.instance.collection('TrackedHabits');
  List<Map<String, dynamic>> habitList = [{}];

  //create note

  Future<void> addNote(String title, String note) {
    return notes.add({
      'title': title,
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

//create Task

  Future<void> addTask(String task, bool isCompleted, String due) {
    return tasks.add({
      'task': task,
      'due': due,
      'isCompleted': isCompleted,
      'timestamp': Timestamp.now(),
    });
  }

  //create habit

  Future<void> addHabit(String habitName, bool isCompleted) async {
    await habits.add({
      'name': habitName,
      'isCompleted': isCompleted,
      'timestamp': Timestamp.now(),
    });
  }

//Read Notes

  Stream<QuerySnapshot> getNotesStream() {
    final notesStream = notes.orderBy('timestamp', descending: true)
        .snapshots();
    return notesStream;
  }

//Read Tasks

  Stream<QuerySnapshot> getTasksStream() {
    final taskStream = tasks.orderBy('timestamp', descending: true).snapshots();
    return taskStream;
  }

  // Read Habits
  Stream<QuerySnapshot> getHabitStream() {
    final habitStream = habits.orderBy('timestamp', descending: true).snapshots();
    return habitStream;
  }

  // //Read Habits
  // Future<List<Map<String, dynamic>>> loadHabitData() async {
  //   QuerySnapshot snapshot = await habits.orderBy('timestamp', descending: true)
  //       .limit(1)
  //       .get();
  //   if (snapshot.docs.isNotEmpty) {
  //     DocumentSnapshot latestSnapshot = snapshot.docs.first;
  //     List<Map<String, dynamic>> habitList = List<Map<String, dynamic>>.from(
  //         latestSnapshot['habits']);
  //     return habitList;
  //   }
  //   return [];
  // }

//Update Notes
  Future <void> updateNote(String docId, String newTitle, String newNote) {
    return notes.doc(docId).update({
      'title': newTitle,
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //Update Habit
  Future<void> updateHabitDatabase(String docId,String newHabitName)  {
    return habits.doc(docId).update(
        {'name': newHabitName,  'timestamp': Timestamp.now()});
  }


  //completeTask
  Future<void> completeTask(String docId, bool value) {
    return tasks.doc(docId).update({
      'isCompleted': value,
      'timestamp': Timestamp.now(),
    });
  }

  // //completedHabit
  Future<void> completeHabit(String docId, bool value) {
    return habits.doc(docId).update({
      'isCompleted': value,
      'timestamp': Timestamp.now(),
    });
  }

//delete Note

  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }

  //delete Task
  Future<void> deleteTask(String docId) {
    return tasks.doc(docId).delete();
  }

  //delete habit
  Future<void> deleteHabit(String docId) {
    return habits.doc(docId).delete();
  }

//habit code


  // Calculate habit percentages
  Future<void> calculateHabitPercentages() async {
    String todayKey = DateTime.now().toIso8601String().split('T')[0];
    DocumentSnapshot snapshot = await habits.doc(todayKey).get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> habitList = List<Map<String, dynamic>>.from(snapshot['habits']);
      int countCompleted = habitList.where((habit) => habit['isCompleted'] as bool).length;
      String percent = habitList.isEmpty ? '0.0' : (countCompleted / habitList.length).toStringAsFixed(1);
      await habits.doc(todayKey).update({'percentage': percent});
    }
  }

  // // Load heatmap data
  Future<Map<DateTime, int>> loadHeatMap() async {
    QuerySnapshot querySnapshot = await habits.get();
    Map<DateTime, int> heatMapDataSet = {};
    for (var doc in querySnapshot.docs) {
      if (doc.id != 'HABITLIST') {
        DateTime date = DateTime.parse(doc.id); // assuming doc.id is in YYYY-MM-DD format
        double strengthAsPercent = double.parse(doc['percentage'] ?? '0.0');
        heatMapDataSet[date] = (10 * strengthAsPercent).toInt();
      }
    }
    return heatMapDataSet;
  }
}



