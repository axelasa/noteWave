import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:note_wave/core/common/app_button.dart';
import 'package:note_wave/core/common/app_color.dart';
import 'package:note_wave/core/common/app_input.dart';
import 'package:note_wave/data/local_storage.dart';
import 'package:note_wave/features/pages/monthlysummary/monthly_summary.dart';
import 'package:note_wave/utills/habit_tile.dart';

import '../../../service/firstore_service.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final _storage = Hive.box('storage');

  HabitDataBase db = HabitDataBase();
  FireStoreService service = FireStoreService();

  @override
  void initState() {
    super.initState();
    if (_storage.get('HABITLIST') == null) {
      db.createInitialHabitData();
    } else {
      //load existing data
      db.loadHabitData();
      db.loadHeatMap();
    }
  }

  TextEditingController habitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        child: const Icon(Icons.add),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                //monthly summary heat map
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MonthlySummary(
                    datasets: db.heatMapDataSet,
                    startDate: _storage.get("START_DATE"),
                  ),
                ),
            
                //list of habits
                
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: db.habitList.length,
                    itemBuilder: (context, i) {
                      // Check if db.habitList[i] is not null
                      if (db.habitList[i] != null && db.habitList[i].length >= 2) {
                        return HabitTile(
                          habitName: db.habitList[i][0],
                          habitCompleted: db.habitList[i][1],
                          onChanged: (value) => checkBoxChanged(value, i),
                          settingsTapped: (context) => openHabitSettings(i),
                          deleteTapped: (context) => deleteHabit(i),
                        );
                      } else {
                        // Handle the case where db.habitList[i] is null or doesn't have enough elements
                        // This could be a loading issue or data corruption
                        return Container(); // or some placeholder widget
                      }
                    }
                )
            
              ],
            ),
          )
        ],
      ),
    );
  }

  //function for the tapped checkbox
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.habitList[index][1] = value;
    });
    db.updateHabitDatabase();
  }

  //create a new habit
  void createNewHabit() {
    //create alertDialog to enter new Habit details
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Habit',
              style: GoogleFonts.hahmlet(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            content: AppInput(
              label: 'Add habit to track',
              type: TextInputType.text,
              controller: habitController,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppButton(
                    textColor: Colors.black,
                    backgroundColor: AppColors.warningColor,
                    borderColor: AppColors.warningColor,
                    text: 'Save',
                    onClicked: saveNewHabit,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  AppButton(
                    textColor: Colors.black,
                    backgroundColor: AppColors.warningColor,
                    borderColor: AppColors.warningColor,
                    text: 'Cancel',
                    onClicked: cancelHabit,
                  ),
                ],
              )
            ],
          );
        });
  }

  //save a new habit
  void saveNewHabit() {
    if (habitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit before clicking save.'),
        ),
      );
    } else {
      setState(() {
        //service.addTask(habitController.text, false);
        db.habitList.add([habitController.text, false]);
      });
      habitController.clear();
      cancelHabit();
      db.updateHabitDatabase();
    }
  }

  //open habit settings to edit
  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Habit',
              style: GoogleFonts.hahmlet(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            content: AppInput(
              label: db.habitList[index][0],
              type: TextInputType.text,
              controller: habitController,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppButton(
                    textColor: Colors.black,
                    backgroundColor: AppColors.warningColor,
                    borderColor: AppColors.warningColor,
                    text: 'Save',
                    onClicked: () => saveExistingHabit(index),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  AppButton(
                    textColor: Colors.black,
                    backgroundColor: AppColors.warningColor,
                    borderColor: AppColors.warningColor,
                    text: 'Cancel',
                    onClicked: cancelHabit,
                  ),
                ],
              )
            ],
          );
        });
  }

  void saveExistingHabit(int index) {
    if (habitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit before clicking save.'),
        ),
      );
    } else {
      setState(() {
        db.habitList[index][0] = habitController.text;
      });
      habitController.clear();
      cancelHabit();
      db.updateHabitDatabase();
    }
  }

  // delete habit
  void deleteHabit(int index,{String? docId}) {
    //service.deleteHabit(docId!);
    setState(() {
      db.habitList.removeAt(index);
    });
    db.updateHabitDatabase();
  }

  //cancel creating a habit
  void cancelHabit() {
    Navigator.pop(context);
  }
}
