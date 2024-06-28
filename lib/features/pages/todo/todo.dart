import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:note_wave/constants/note_color.dart';
import 'package:note_wave/data/local_storage.dart';
import 'package:note_wave/utills/todo_dialog_widget.dart';
import 'package:note_wave/utills/todo_tile.dart';
import '../../../core/common/app_input.dart';
import '../../../service/firstore_service.dart';
import '../../../utills/time_stamp.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../../widget/app_toast.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _storage = Hive.box('storage');

  ToDoDataBase db = ToDoDataBase();
  FireStoreService service = FireStoreService();

  DateTime date = DateTime.now();

  //Color selectedColor = Colors.white;
  Color currentColor = Colors.yellow.shade100;
  Color pickerColor = Colors.white;
  int position = 0;
  TextEditingController dueDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_storage.get('TODOLIST') == null) {
      db.createInitialData();
    } else {
      //load existing data
      db.loadData();
    }
  }

  TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getTasksStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasData) {
            List taskList = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: taskList.length,
              itemBuilder: (context, i) {
                //get each individual document
                DocumentSnapshot document = taskList[i];
                String docId = document.id;

                //get task from each document
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String task = data['task'];
                bool isCompleted = data['isCompleted'];
                String dueOn = data['due'];

                Color taskColor = tasksColor[i % tasksColor.length];

                return TodoTile(
                  color: taskColor,
                  taskName: task,
                  dueDate: dueOn,
                  taskCompleted: isCompleted,
                  onChanged: (value) {
                    checkBoxChanged(value, i, docId: docId);
                  },
                  deleteFunction: (context) {
                    deleteTask(index: i, docId: docId);
                  },
                );
              },
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: db.toDoList.length,
            itemBuilder: (BuildContext context, int index) {
              Color taskColor = tasksColor[index % cardsColor.length];
              return TodoTile(
                // onPressed: ()=> showPicker(),
                color: taskColor,
                taskName: db.toDoList[index][0],
                dueDate: db.toDoList[index][0],
                taskCompleted: db.toDoList[index][1],
                onChanged: (value) => checkBoxChanged(value, index),
                deleteFunction: (context) => deleteTask(index: index),
              );
            },
          );
        },
      ),
    );
  }

  void checkBoxChanged(bool? value, int index, {String? docId}) async {
    if (docId == null) {
      debugPrint('No docId');
      showSnackBar(
          message: "No Tasks Available ",
          title: "Task",
          contentType: ContentType.warning, context: context);
      return;
    } else {
      debugPrint('Here is the docId: $docId');
      try {
        await service.completeTask(docId, value!);
        debugPrint('Task completed successfully for docId: $docId');

        setState(() {
          db.toDoList[index][1] = !db.toDoList[index][1];
        });
        db.updateDatabase();
      } catch (e) {
        debugPrint('Error completing task: $e');
      }
    }
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: taskController,
          onSave: saveNewTask,
          onCancel: () {
            Navigator.pop(context);
          },
          //icon button
          onPress: _showDatePicker,
          appInput: AppInput(
              label: 'select due date',
              type: TextInputType.none,
              controller: dueDate,
              text: dueDate.text),
        );
      },
    );
  }

  void saveNewTask() {
    if (taskController.text.isEmpty) {
      _showSnackBar(
        message: "Please Enter A task Before clicking save",
        title: "Task",
        contentType: ContentType.warning,
      );
    } else {
      setState(
        () {
          service.addTask(taskController.text, false, formattedDateTime(date));
          db.toDoList
              .add([taskController.text, false, formattedDateTime(date)]);
          taskController.clear();
          Navigator.pop(context);
          db.updateDatabase();
        },
      );
      showSnackBar(
        message: "Your task has been saved",
        title: "Success",
        contentType: ContentType.success, context: context,
      );
    }
  }

  void deleteTask({required int index, String? docId}) {
    setState(
      () {
        if (docId != null) {
          service.deleteTask(docId);
        } else {
          db.toDoList.removeAt(index);

          db.updateDatabase();
        }
      },
    );
  }

  void _showDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(3050))
        .then((value) {
      setState(() {
        String formatedDate = DateFormat("yyyy-MM-dd").format(value!);

        dueDate.text = formatedDate;
      });
    });
  }

  void changeColor(Color color) {
    setState(() => currentColor = color);
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
