import 'package:flutter/material.dart';
import 'package:note_wave/core/common/app_color.dart';

class MyButton extends StatelessWidget {
  final String buttonName;
  VoidCallback onPressed;
   MyButton({super.key, required this.buttonName,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(onPressed: onPressed,
        color: Colors.yellow,
      child: Text(buttonName),
    );
  }
}
