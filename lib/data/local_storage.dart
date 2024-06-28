
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../components/datetime/date_time.dart';


class ToDoDataBase{

  final _storage = Hive.box('storage');
  List toDoList = [];


  //this is run when the app is run for the very first time
  void createInitialData(){
  toDoList = [
      ['First Task', false,''],
      ['Second Task', false,'']
    ];
  }
  //load data from local storage
  void loadData(){
    toDoList = _storage.get('TODOLIST');
  }

  //update the data base
  void updateDatabase(){
    _storage.put('TODOLIST',toDoList);
  }
}

// class NoteDataBase{
//   List noteList = [];
//   final _storage = Hive.box('storage');
//
//   //this is run when the app is run for the very first time
//   void createInitialData(){
//     noteList = [
//       ['First Task', '',''],
//       ['Second Task', '','']
//     ];
//   }
//
//   //load data from db
//   void loadNote(){
//
//     noteList = _storage.get('NOTELIST');
//   }
//   //update the db
//   void updateNoteListDataBase(){
//     noteList = _storage.get('NOTELIST',noteList);
//   }
// }



class HabitDataBase{

  final _storage = Hive.box('storage');
  List habitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  //this is run when the app is run for the very first time
  void createInitialHabitData(){
    habitList =[
      ['First Habit',false],
      ['second Habit',false]
    ];
    _storage.put('START_DATE', todaysDateFormatted());
  }

  //load data from local storage
  void loadHabitData(){
    //check if it's a new day, get habit list from database
    if(_storage.get(todaysDateFormatted()) == null){
      habitList = _storage.get('HABITLIST');
      //set all habits completed to false since its a new day
      for (int i =0; i<habitList.length; i++){
        habitList[i][1] = false;
      }
    }
    //if it's not new day load today's list
    else{
      habitList = _storage.get('HABITLIST');
      loadHeatMap();
    }
  }
  void updateHabitDatabase(){
    //update today's entry
    _storage.put(todaysDateFormatted(), habitList);
    // update universal habit list in case it changed (new habit, edit habit, delete habit)
    _storage.put('HABITLIST', habitList);

    //calculate Habit percentages
     calculateHabitPercentages();
    //load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages(){
    int countCompleted = 0;
    for (int i = 0; i < habitList.length; i++) {
      if (habitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = habitList.isEmpty
        ? '0.0'
        : (countCompleted / habitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _storage.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_storage.get("START_DATE"));

    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _storage.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      debugPrint('$heatMapDataSet');
    }
  }
}