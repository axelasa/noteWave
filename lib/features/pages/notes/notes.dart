import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_wave/core/common/app_button.dart';
import 'package:note_wave/core/common/app_input.dart';
import 'package:note_wave/service/firstore_service.dart';
import 'package:note_wave/utills/time_stamp.dart';
import '../../../constants/note_color.dart';
import '../../../widget/app_toast.dart';
import 'note_data.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FireStoreService service = FireStoreService();

  // @override
  // void dispose() {
  //   titleController.dispose();
  //   noteController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[200],
        onPressed: () {
          publishNote();
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: service.getNotesStream(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Please swipe down to reload your the app'),
              );
            }
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AlignedGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: notesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    //get each individual document
                    DocumentSnapshot document = notesList[index];
                    String docId = document.id;

                    //get note from each document
                    Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                    String title = data['title'];
                    String note = data['note'].replaceAll("\\n", "\n");
                    Timestamp timestamp = data['timestamp'];

                    // Determine the color for this card
                    Color cardColor = cardsColor[index % cardsColor.length];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesDataPage(
                              title: title,
                              note: note,
                              timestamp: timestamp,
                              docId: docId,
                            ),
                          ),
                        );
                      },
                        // for(int i =0; i< cardsColor.length; i ++)
                      child: Card(
                        elevation: 2,
                        shadowColor: Colors.grey.shade100,
                        color: cardColor,
                        child: Column(
                          children: [
                            //title of the note
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0,left: 8.0,right:8.0 ),
                              child: Text(
                                title,
                                style: GoogleFonts.robotoCondensed(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            //time note was taken
                            Text(
                              formattedTimestamp(timestamp),
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                note,
                                softWrap: false,
                                maxLines: null,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dosis(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    service.deleteNote(docId);

                                  },
                                  icon: const Icon(Icons.delete),
                                  iconSize: 20,
                                  color: Colors.black,
                                ),
                                IconButton(
                                  onPressed: () {
                                    publishNote(docId: docId,title:title ,note:note ,);
                                  },
                                  icon: const Icon(Icons.edit),
                                  iconSize: 20,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  //staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                ),
              );
            } else {
              return const Center(
                child: Text('No Notes Available...'),
              );
            }
          },
        ),
      ),
    );
  }

  void publishNote({String? docId,String? title, String? note}) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController noteController = TextEditingController(text: note);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('New Note')),
          titlePadding: const EdgeInsets.all(8.0),
          titleTextStyle: GoogleFonts.akshar(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.yellow[200],
          content: Form(
            key: _formKey,
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInput(
                    label: 'Title',
                    type: TextInputType.text,
                    controller: titleController,
                    validator: (val) =>
                    val!.isEmpty ? '*Provide title for your note' : null,
                    onChanged: (val) {
                      titleController.text = val;
                    },
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: AppInput(
                        label: 'Note',
                        type: TextInputType.multiline,
                        controller:noteController,
                        validator: (val) =>
                        val!.isEmpty ? '*Can not publish an empty note' : null,
                        onChanged: (val) {
                          noteController.text = val;
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppButton(
                  textColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  borderColor: Colors.yellow.shade200,
                  text: 'cancel',
                  onClicked: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 10,),
                AppButton(
                  textColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  borderColor: Colors.yellow.shade200,
                  text: 'publish',
                  onClicked: () {
                    if (_formKey.currentState!.validate()) {
                      if (docId == null) {
                        //add the new note
                        service.addNote(titleController.text, noteController.text);
                        Navigator.pop(context);
                        showSnackBar(
                            message: "Note Published",
                            title: "Success",
                            contentType: ContentType.success, context: context);
                      } else {
                        service.updateNote(docId, titleController.text, noteController.text);
                        Navigator.pop(context);
                        showSnackBar(
                            message: "Note Updated ",
                            title: "Success",
                            contentType: ContentType.success, context: context);
                      }
                    }
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }
  // void deleteNote({required int index, String? docId}) {
  //   setState(
  //         () {
  //       if (docId != null) {
  //         service.deleteTask(docId);
  //       } else {
  //         db.toDoList.removeAt(index);
  //
  //         db.updateDatabase();
  //       }
  //     },
  //   );
  // }
}
