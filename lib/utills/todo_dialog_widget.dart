import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:note_wave/constants/note_color.dart';
import 'package:note_wave/core/common/app_input.dart';
import 'package:note_wave/utills/my_button.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onPress;
  final Widget appInput;


  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.onPress,
    required this.appInput,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[200],
      content: SizedBox(
        height: 205,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'New Task',
                  //hintStyle:,
                  labelText: 'Add A Task'),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(
                  buttonName: 'Save',
                  onPressed: onSave,
                ),
                const SizedBox(
                  width: 15,
                ),
                MyButton(
                  buttonName: 'Cancel',
                  onPressed: onCancel,
                )
              ],
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: onPress,
                    label: const Icon(Icons.calendar_month),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 175,
                        height: 50,
                        child: appInput,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Wrap(
            //       children: List.generate(
            //         tasksColor.length,
            //         (index) {
            //           Color cardColor = tasksColor[index % cardsColor.length];
            //           return GestureDetector(
            //             onTap: ()=> selectedColor,
            //             child: Column(
            //               children: [
            //                 TextButton(
            //                   onPressed: onClick,
            //                   child:const Text('SelectColor'), ),
            //               ],
            //             ),
            //           );
            //         },
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

}

// Container(
// height: 15,
// width:15,
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(10)
// ),
// child: CircleAvatar(
// radius: 15,
// backgroundColor: color,
// ),
// )

// Card(
// child: CircleAvatar(
// radius: 15,
// backgroundColor: cardColor,
// ),
// ),