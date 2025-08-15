import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:note_wave/habit_model/habit_model.dart';

import '../components/datetime/date_time.dart';

class FireStoreService {
  final notes = FirebaseFirestore.instance.collection('notes');
  final tasks = FirebaseFirestore.instance.collection('tasks');
  final habits = FirebaseFirestore.instance.collection('TrackedHabits');
  final heatMapData = FirebaseFirestore.instance.collection('heatMapData');
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

    // After adding a habit, recalculate and save today's percentage
    await calculateAndSaveHabitPercentage();
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

  //Update Notes
  Future <void> updateNote(String docId, String newTitle, String newNote) {
    return notes.doc(docId).update({
      'title': newTitle,
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //Update Habit
  Future<void> updateHabitDatabase(String docId,String newHabitName) async {
    await habits.doc(docId).update(
        {'name': newHabitName,  'timestamp': Timestamp.now()});

    // Recalculate percentage after updating habit
    await calculateAndSaveHabitPercentage();
  }

  //completeTask
  Future<void> completeTask(String docId, bool value) {
    return tasks.doc(docId).update({
      'isCompleted': value,
      'timestamp': Timestamp.now(),
    });
  }

  // //completedHabit
  Future<void> completeHabit(String docId, bool value) async {
    await habits.doc(docId).update({
      'isCompleted': value,
      'timestamp': Timestamp.now(),
    });

    // After completing/uncompleting a habit, recalculate today's percentage
    await calculateAndSaveHabitPercentage();
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
  Future<void> deleteHabit(String docId) async {
    await habits.doc(docId).delete();

    // After deleting a habit, recalculate today's percentage
    await calculateAndSaveHabitPercentage();
  }

  // ============ NEW HEAT MAP METHODS ============

  // Save daily habit completion percentage to Firestore
  Future<void> saveDailyPercentage(String date, double percentage) async {
    try {
      await heatMapData.doc(date).set({
        'date': date,
        'percentage': percentage,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to update if exists
      debugPrint('Saved daily percentage for $date: $percentage');
    } catch (e) {
      debugPrint('Error saving daily percentage: $e');
    }
  }

  // Get daily percentage from Firestore
  Future<double?> getDailyPercentage(String date) async {
    try {
      DocumentSnapshot doc = await heatMapData.doc(date).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['percentage']?.toDouble();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting daily percentage: $e');
      return null;
    }
  }

  // Calculate and save today's habit completion percentage
  Future<void> calculateAndSaveHabitPercentage() async {
    try {
      // Get today's date in the same format as your local storage
      String todayDate = todaysDateFormatted(); // Use your existing date formatter

      // Get today's habits
      QuerySnapshot snapshot = await habits.get();
      List<DocumentSnapshot> todayHabits = snapshot.docs;

      if (todayHabits.isEmpty) {
        await saveDailyPercentage(todayDate, 0.0);
        return;
      }

      int completedCount = 0;
      for (DocumentSnapshot doc in todayHabits) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bool isCompleted = data['isCompleted'] ?? false;
        if (isCompleted) {
          completedCount++;
        }
      }

      double percentage = completedCount / todayHabits.length;
      await saveDailyPercentage(todayDate, percentage);

      debugPrint('Calculated and saved percentage for $todayDate: $percentage (completed: $completedCount/${ todayHabits.length})');

    } catch (e) {
      debugPrint('Error calculating habit percentage: $e');
    }
  }

  // Load heat map data from Firestore (improved version of your existing method)
  Future<Map<DateTime, int>> loadFirebaseHeatMap(DateTime startDate) async {
    Map<DateTime, int> heatMapDataSet = {};

    try {
      // Calculate days between start date and today
      int daysInBetween = DateTime.now().difference(startDate).inDays;

      // Get all heat map documents
      QuerySnapshot snapshot = await heatMapData.orderBy('date').get();

      // Create a map for quick lookup
      Map<String, double> percentageData = {};
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        percentageData[doc.id] = data['percentage']?.toDouble() ?? 0.0;
      }

      // Build heat map data for each day in the range
      for (int i = 0; i <= daysInBetween; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String dateString = convertDateTimeToString(currentDate); // Use your existing date converter

        double percentage = percentageData[dateString] ?? 0.0;

        // Convert percentage to heat map intensity (0-10)
        heatMapDataSet[DateTime(currentDate.year, currentDate.month, currentDate.day)] =
            (10 * percentage).toInt();
      }

      debugPrint('Loaded Firebase heat map with ${heatMapDataSet.length} entries');
    } catch (e) {
      debugPrint('Error loading Firebase heat map: $e');
    }

    return heatMapDataSet;
  }

  // Stream for real-time heat map updates
  Stream<Map<DateTime, int>> getHeatMapStream(DateTime startDate) async* {
    await for (QuerySnapshot snapshot in heatMapData.snapshots()) {
      Map<DateTime, int> heatMapDataSet = {};

      // Calculate days between start date and today
      int daysInBetween = DateTime.now().difference(startDate).inDays;

      // Create a map for quick lookup
      Map<String, double> percentageData = {};
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        percentageData[doc.id] = data['percentage']?.toDouble() ?? 0.0;
      }

      // Build heat map data for each day in the range
      for (int i = 0; i <= daysInBetween; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String dateString = convertDateTimeToString(currentDate);

        double percentage = percentageData[dateString] ?? 0.0;
        heatMapDataSet[DateTime(currentDate.year, currentDate.month, currentDate.day)] =
            (10 * percentage).toInt();
      }

      yield heatMapDataSet;
    }
  }

  // Migration method to move local heat map data to Firebase (one-time use)
  Future<void> migrateLocalHeatMapToFirebase() async {
    try {
      final storage = Hive.box('storage');
      String? startDateString = storage.get("START_DATE");

      if (startDateString == null) {
        debugPrint('No start date found for migration');
        return;
      }

      DateTime startDate = createDateTimeObject(startDateString);
      int daysInBetween = DateTime.now().difference(startDate).inDays;

      int migratedDays = 0;
      for (int i = 0; i <= daysInBetween; i++) {
        String dateString = convertDateTimeToString(startDate.add(Duration(days: i)));
        String? percentageString = storage.get("PERCENTAGE_SUMMARY_$dateString");

        if (percentageString != null) {
          double percentage = double.parse(percentageString);
          await saveDailyPercentage(dateString, percentage);
          migratedDays++;
        }
      }

      debugPrint('Heat map data migration completed: $migratedDays days migrated');
    } catch (e) {
      debugPrint('Error migrating heat map data: $e');
    }
  }

  // ============ MODIFIED EXISTING METHODS ============

  // Calculate habit percentages (keeping your existing method but improved)
  Future<void> calculateHabitPercentages() async {
    String todayKey = DateTime.now().toIso8601String().split('T')[0];
    DocumentSnapshot snapshot = await habits.doc(todayKey).get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> habitList = List<Map<String, dynamic>>.from(snapshot['habits']);
      int countCompleted = habitList.where((habit) => habit['isCompleted'] as bool).length;
      String percent = habitList.isEmpty ? '0.0' : (countCompleted / habitList.length).toStringAsFixed(1);
      await habits.doc(todayKey).update({'percentage': percent});

      // Also save to new heat map collection
      await saveDailyPercentage(todaysDateFormatted(), double.parse(percent));
    }
  }

  // Load heatmap data (keeping your existing method as fallback)
  Future<Map<DateTime, int>> loadHeatMap() async {
    try {
      // Try to load from new heat map collection first
      final storage = Hive.box('storage');
      String? startDateString = storage.get("START_DATE");

      if (startDateString != null) {
        DateTime startDate = createDateTimeObject(startDateString);
        Map<DateTime, int> firebaseHeatMap = await loadFirebaseHeatMap(startDate);
        if (firebaseHeatMap.isNotEmpty) {
          return firebaseHeatMap;
        }
      }

      // Fallback to your existing method
      QuerySnapshot querySnapshot = await habits.get();
      Map<DateTime, int> heatMapDataSet = {};
      for (var doc in querySnapshot.docs) {
        if (doc.id != 'HABITLIST') {
          try {
            DateTime date = DateTime.parse(doc.id); // assuming doc.id is in YYYY-MM-DD format
            double strengthAsPercent = double.parse(doc['percentage'] ?? '0.0');
            heatMapDataSet[date] = (10 * strengthAsPercent).toInt();
          } catch (e) {
            // Skip invalid date formats
            continue;
          }
        }
      }
      return heatMapDataSet;
    } catch (e) {
      debugPrint('Error loading heat map: $e');
      return {};
    }
  }
}



