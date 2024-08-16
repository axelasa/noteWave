import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

// typedef void StringCallback(String text);

class AppInput extends StatefulWidget {
  final String label;
  final dynamic type;
  final bool isIcon;
  final IconData? icon;
  final bool? isReadOnly;
  final String? text;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  final Function? onTap;
  final TextEditingController controller;
  const AppInput(
      {Key? key,
      required this.label,
      this.isIcon = false,
      this.icon,
      required this.type,
      required this.controller,
      this.onTap,
      this.text,
      this.isReadOnly,
        this.validator,
        this.onChanged,
      })
      : super(key: key);

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  Widget inputIcon() {
    return widget.isIcon == false ? const Icon(null) : Icon(widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        widget.isReadOnly == true ? widget.onTap!() : null;
      },
      controller: widget.controller,
      keyboardType: widget.type,
      maxLines: widget.type == TextInputType.multiline ? 3 : 1,
      readOnly: widget.isReadOnly == true,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: const TextStyle(
          color: Colors.black,
          fontSize: 17.0,
          fontFamily: AppFont.font,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: widget.text,
        contentPadding: const EdgeInsets.all(10.0),
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: Color(0xff979797),
          fontSize: 17.0,
          fontFamily: AppFont.font,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xffb9b9bb),
          ),
        ),
        prefixIcon: inputIcon(),
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
