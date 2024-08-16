import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

// typedef void StringCallback(String text);

class AppInputSmall extends StatefulWidget {
  final String label;
  final dynamic type;
  final bool isIcon;
  final IconData? icon;
  final bool? isReadOnly;
  final String? text;

  final Function? onTap;
    final Function(String)? onChanged;

  final TextEditingController controller;
  const AppInputSmall(
      {Key? key,
      required this.label,
      this.isIcon = false,
      this.icon,
      required this.type,
      required this.controller,
      this.onChanged,
      this.onTap,
      this.text,
      
      this.isReadOnly})
      : super(key: key);

  @override
  State<AppInputSmall> createState() => _AppInputSmallState();
}

class _AppInputSmallState extends State<AppInputSmall> {
  Widget inputIcon() {
    return widget.isIcon == false ? const Icon(null) : Icon(widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        widget.isReadOnly == true
            ? widget.onTap != null
                ? widget.onTap!()
                : null
            : null;
      },
      onChanged:widget.onChanged,
      controller: widget.controller,
      keyboardType: widget.type,
      maxLines: widget.type == TextInputType.multiline ? 3 : 1,
      readOnly: widget.isReadOnly == true,
      style: const TextStyle(
          color: Colors.black,
          fontSize: 12.0,
          fontFamily: AppFont.font,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintStyle: const TextStyle(fontFamily: AppFont.font),
        hintText: widget.label,
      

        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(5.0),
        // labelText: widget.label,
        prefixText: '  ',
        labelStyle: const TextStyle(
          color: Color(0xff979797),
          fontSize: 12.0,
          fontFamily: AppFont.font,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xffb9b9bb),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppColors.mainColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
