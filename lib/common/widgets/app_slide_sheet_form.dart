import 'package:flutter/material.dart';

import 'app_font.dart';

class AppSlideSheetForm extends StatefulWidget {
  final String title;
  final Widget form;
  const AppSlideSheetForm({
    Key? key,
    required this.title,
    required this.form,
  }) : super(key: key);

  @override
  State<AppSlideSheetForm> createState() => _AppSlideSheetFormState();
}

class _AppSlideSheetFormState extends State<AppSlideSheetForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10,
          top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontFamily: AppFont.font,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          widget.form,
        ],
      ),
    );
  }
}
