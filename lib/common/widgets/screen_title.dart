import 'package:flutter/material.dart';

import 'app_font.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  const ScreenTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontFamily: AppFont.font,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
