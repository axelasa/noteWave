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
  Map<DateTime, int> firebaseHeatMapDataSet = {};

  String? documentId;
  late DateTime startDate;
  bool isLoadingHeatMap = false;

  @override
  void initState() {
    super.initState();
    initializeStartDate();
    loadHeatMapData();

    if (_storage.get('HABITLIST') == null) {
      db.createInitialHabitData();
    } else {
      //load existing data
      db.loadHabitData();
      db.loadHeatMap();
    }
  }

  TextEditingController habitController = TextEditingController();

  void initializeStartDate() {
    // Try to get start date from local storage first
    String? storedStartDate = _storage.get("START_DATE");
    if (storedStartDate != null) {
      startDate = createDateTimeObject(storedStartDate);
    } else {
      // If no start date exists, use today and save it
      startDate = DateTime.now();
      _storage.put('START_DATE', convertDateTimeToString(startDate));
    }
  }

  Future<void> loadHeatMapData() async {
    setState(() {
      isLoadingHeatMap = true;
    });

    try {
      // Load Firebase heat map data
      firebaseHeatMapDataSet = await service.loadFirebaseHeatMap(startDate);

      // Load local heat map as fallback
      heatMapDataSet = await service.loadHeatMap();

      debugPrint('Firebase heat map entries: ${firebaseHeatMapDataSet.length}');
      debugPrint('Local heat map entries: ${heatMapDataSet.length}');

    } catch (e) {
      debugPrint('Error loading heat map data: $e');
    } finally {
      setState(() {
        isLoadingHeatMap = false;
      });
    }
  }

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
                // Heat map section with loading indicator
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: isLoadingHeatMap
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : MonthlySummary(
                    datasets: firebaseHeatMapDataSet.isNotEmpty
                        ? firebaseHeatMapDataSet
                        : heatMapDataSet, // Fallback to local data
                    startDate: convertDateTimeToString(startDate),
                  ),
                ),

                // StreamBuilder for habits with real-time heat map updates
                StreamBuilder(
                  stream: service.getHabitStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      showSnackBar(
                        context: context,
                        message: "${snapshot.error}",
                        title: 'Error',
                        contentType: ContentType.failure,
                      );
                      return Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No habits found. Add your first habit!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    List habitList = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habitList.length,
                      itemBuilder: (context, i) {
                        //get each individual document
                        DocumentSnapshot document = habitList[i];
                        String docId = document.id;
                        documentId = docId;

                        //get task from each document
                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                        String habit = data['name'] ?? "";
                        bool isCompleted = data['isCompleted'] ?? false;

                        return HabitTile(
                          habitName: habit,
                          habitCompleted: isCompleted,
                          onChanged: (value) {
                            checkBoxChanged(value, i, docId: docId);
                          },
                          deleteTapped: (context) => deleteHabit(i, docId: docId),
                          settingsTapped: (context) => openHabitSettings(i, docId: docId),
                        );
                      },
                    );
                  },
                )
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
          message: "No Habits Available",
          title: "Habit",
          contentType: ContentType.warning,
          context: context);
      return;
    }

    try {
      // Update habit completion status
      await service.completeHabit(docId, value!);
      debugPrint('Task completed successfully for docId: $docId');

      // Update local data for immediate UI response
      setState(() {
        if (index < db.habitList.length && db.habitList[index].length >= 2) {
          db.habitList[index][1] = value;
        }
      });
      db.updateHabitDatabase();

      // Reload heat map data to reflect the change
      await loadHeatMapData();

    } catch (e) {
      debugPrint('Error completing Habit: $e');
      showSnackBar(
        context: context,
        message: "Error updating habit: $e",
        title: "Error",
        contentType: ContentType.failure,
      );
    }
  }

  //create a new habit
  void createNewHabit() {
    habitController.clear(); // Clear the controller
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Add New Habit',
                    style: GoogleFonts.hahmlet(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input field
                  AppInput(
                    label: 'Add habit to track',
                    type: TextInputType.text,
                    controller: habitController,
                  ),
                  const SizedBox(height: 30),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          textColor: Colors.black,
                          backgroundColor: Colors.grey[200]!,
                          borderColor: Colors.grey[300]!,
                          text: 'Cancel',
                          onClicked: cancelHabit,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          textColor: Colors.white,
                          backgroundColor: AppColors.warningColor,
                          borderColor: AppColors.warningColor,
                          text: 'Save',
                          onClicked: saveNewHabit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //save a new habit
  void saveNewHabit() async {
    if (habitController.text.isEmpty) {
      _showSnackBar(
        message: "Please Enter A habit Before clicking save",
        title: "Habit",
        contentType: ContentType.warning,
      );
    } else {
      try {
        // Add habit to Firebase (this will automatically update the heat map)
        await service.addHabit(habitController.text, false);

        // Update local data
        setState(() {
          db.habitList.add([habitController.text, false]);
        });
        db.updateHabitDatabase();

        // Reload heat map data
        await loadHeatMapData();

        habitController.clear();
        cancelHabit();

        _showSnackBar(
          message: "Habit added successfully!",
          title: "Success",
          contentType: ContentType.success,
        );

      } catch (e) {
        debugPrint('Error saving new habit: $e');
        _showSnackBar(
          message: "Error adding habit: $e",
          title: "Error",
          contentType: ContentType.failure,
        );
      }
    }
  }

  //open habit settings to edit
  void openHabitSettings(int index, {String? docId}) {
    // Pre-populate the text field with current habit name
    if (index < db.habitList.length && db.habitList[index].length >= 1) {
      habitController.text = db.habitList[index][0] ?? '';
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Edit Habit',
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
                    onClicked: () => saveExistingHabit(index, docId: docId),
                  ),
                  const SizedBox(width: 12),
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

  void saveExistingHabit(int index, {String? docId}) async {
    if (habitController.text.isEmpty) {
      _showSnackBar(
        message: "Please enter a habit before clicking save.",
        title: "Habit",
        contentType: ContentType.warning,
      );
    } else if (docId == null) {
      _showSnackBar(
        message: "Error: No habit ID found.",
        title: "Error",
        contentType: ContentType.failure,
      );
    } else {
      try {
        // Update habit in Firebase
        await service.updateHabitDatabase(docId, habitController.text);

        // Update local data
        setState(() {
          if (index < db.habitList.length && db.habitList[index].length >= 1) {
            db.habitList[index][0] = habitController.text;
          }
        });
        db.updateHabitDatabase();

        habitController.clear();
        cancelHabit();

        _showSnackBar(
          message: "Habit updated successfully!",
          title: "Success",
          contentType: ContentType.success,
        );

      } catch (e) {
        debugPrint('Error updating habit: $e');
        _showSnackBar(
          message: "Error updating habit: $e",
          title: "Error",
          contentType: ContentType.failure,
        );
      }
    }
  }

  // delete habit
  void deleteHabit(int index, {String? docId}) async {
    try {
      if (docId != null) {
        // Delete from Firebase (this will automatically update the heat map)
        await service.deleteHabit(docId);

        _showSnackBar(
          message: "Habit deleted successfully!",
          title: "Success",
          contentType: ContentType.success,
        );
      }

      // Update local data
      setState(() {
        if (index < db.habitList.length) {
          db.habitList.removeAt(index);
        }
      });
      db.updateHabitDatabase();

      // Reload heat map data
      await loadHeatMapData();

    } catch (e) {
      debugPrint('Error deleting habit: $e');
      _showSnackBar(
        message: "Error deleting habit: $e",
        title: "Error",
        contentType: ContentType.failure,
      );
    }
  }

  //cancel creating a habit
  void cancelHabit() {
    habitController.clear();
    Navigator.pop(context);
  }

  // One-time migration method (call this once if you want to migrate local data)
  void migrateLocalDataToFirebase() async {
    try {
      await service.migrateLocalHeatMapToFirebase();
      await loadHeatMapData();

      _showSnackBar(
        message: "Data migration completed!",
        title: "Success",
        contentType: ContentType.success,
      );
    } catch (e) {
      debugPrint('Error during migration: $e');
      _showSnackBar(
        message: "Error during migration: $e",
        title: "Error",
        contentType: ContentType.failure,
      );
    }
  }

  _showSnackBar({
    required String message,
    required String title,
    required ContentType contentType
  }) {
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
