import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:note_wave/core/common/app_button.dart';
import 'package:note_wave/core/common/app_color.dart';
import 'package:note_wave/core/common/app_input.dart';
import 'package:note_wave/data/local_storage.dart';
import 'package:note_wave/pages/monthlysummary/monthly_summary.dart';
import 'package:note_wave/utills/habit_tile.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../components/datetime/date_time.dart';
import '../../../service/firstore_service.dart';
import '../../widget/app_toast.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final _storage = Hive.box('storage');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  HabitDataBase db = HabitDataBase();
  FireStoreService service = FireStoreService();
  Map<DateTime, int> heatMapDataSet = {};

  String? documentId;

  @override
  void initState() {
    super.initState();
    //loadHabits();
    loadHeatMap();

    if (_storage.get('HABITLIST') == null) {
      db.createInitialHabitData();
    } else {
      //load existing data
      db.loadHabitData();
      db.loadHeatMap();
    }
  }

  TextEditingController habitController = TextEditingController();
  DateTime startDate = DateTime.now();



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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MonthlySummary(
                    datasets: heatMapDataSet,
                    startDate: convertDateTimeToString(startDate), // Ensure correct format
                  ),
                ),
                StreamBuilder(
                    stream: service.getHabitStream(),
                    builder: (context,snapshot){

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if(snapshot.hasError){
                        showSnackBar(
                          context: context, message: "${snapshot.hasError}", title: 'Error', contentType: ContentType.failure,);
                        return  Text("Error, ${snapshot.hasError}",style:const  TextStyle(
                          color: Colors.red,
                        ),);
                      }
                      
                      if (!snapshot.hasData){
                        showSnackBar(
                            context: context, 
                            message: 'No data Found', 
                            title: 'Caution', 
                            contentType: ContentType.warning,);
                        
                        return const Text('No data found',style:TextStyle(
                          color: Colors.red,
                        ),);
                      }
                      
                      if(snapshot.hasData){
                        List habitList = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: habitList.length,
                          itemBuilder: (context, i) {
                            //get each individual document
                            DocumentSnapshot document = habitList[i];
                            String docId = document.id;
                            documentId = docId;
                            //get task from each document
                            Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                            String habit = data['name'];
                            bool isCompleted = data['isCompleted'];


                            return HabitTile(
                              habitName: habit,
                              habitCompleted: isCompleted,
                              onChanged: (value) {
                                checkBoxChanged(value, i, docId: docId);
                              },
                              deleteTapped: (context) => deleteHabit( i, docId: docId),
                              settingsTapped: (context) => openHabitSettings(i,docId:docId),
                            );
                          },
                        );
                      }
                      
                      return Expanded(
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
                      );
                      
                    },)
                
              ],
            ),
          )
        ],
      ),
    );
  }

  //function for the tapped checkbox
  void checkBoxChanged(bool? value, int index, {String? docId}) async {
    if (docId == null) {
      debugPrint('No docId');
      showSnackBar(
          message: "No Habits Available ",
          title: "Habit",
          contentType: ContentType.warning, context: context);
      return;
    }else{
      debugPrint('Here is the Habit docId: $docId');
    }
    try{
      await service.completeHabit(docId,value!);
      debugPrint('Task completed successfully for docId: $docId');

      setState(() {
        db.habitList[index][1] = value;
      });
      db.updateHabitDatabase();
    }catch(e){
      debugPrint('Error completing Habit: $e');
    }

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
      _showSnackBar(
          message: "Please Enter A task Before clicking save",
          title: "Task",
          contentType: ContentType.warning,
      );
    } else {
      setState(() {
        service.addHabit( habitController.text, false,);
        db.habitList.add([habitController.text, false]);
      });
      db.updateHabitDatabase();
      habitController.clear();
      cancelHabit();

    }
  }

  //open habit settings to edit
  void openHabitSettings(int index, {String? docId}) {
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
              // db.habitList[index][0] this line belongs down there on line 209
              label: 'Edit habit',
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
                    onClicked: () => saveExistingHabit(index,docId: docId),
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

  void saveExistingHabit(int index, {String? docId}) {
    if (habitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit before clicking save.'),
        ),
      );
    } else {
      setState(() {
       service.updateHabitDatabase(docId!,habitController.text) ;
        db.habitList[index][0] = habitController.text;
      });
      //service.updateHabitDatabase(habitList);
      db.updateHabitDatabase();
      habitController.clear();
      cancelHabit();
    }
  }

  // delete habit
  void deleteHabit(int index,{String? docId}) {
    //service.deleteHabit(docId!);
    setState(() {
      if(docId != null){
       service.deleteHabit(docId);
      }else{
        db.habitList.removeAt(index);
      }
      db.updateHabitDatabase();
    });
  }

  //cancel creating a habit
  void cancelHabit() {
    Navigator.pop(context);
  }

  // //load habits from db
  // Future<void> loadHabits() async {
  //   habitList = await service.loadHabitData();
  //   setState(() {});
  // }
// create heatmap data
  Future<void> loadHeatMap() async {
    heatMapDataSet = await service.loadHeatMap();
    setState(() {});
  }

  _showSnackBar(
      {required String message,
        required String title,
        required ContentType contentType}) {
    final SnackBar snackBar = SnackBar(
      elevation: 2,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
//
