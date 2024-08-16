import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

// typedef void StringCallback(String text);

class AppPasswordInput extends StatefulWidget {
  final String label;
  final dynamic type;
  final bool isIcon;
  final IconData? icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  const AppPasswordInput({
    Key? key,
    required this.label,
    this.isIcon = false,
    this.icon,
    required this.type,
    required this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _obscureText = true;

  Widget inputIcon() {
    return widget.isIcon == false ? const Icon(null) : Icon(widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.type,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: const TextStyle(
          color: Colors.black,
          fontSize: 17.0,
          fontFamily: AppFont.font,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
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
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
