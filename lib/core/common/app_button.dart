import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class AppButton extends StatefulWidget {
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final double? width;
  final double? height;
  final bool isIcon;
  final IconData? icon;
  final VoidCallback onClicked;
  const AppButton(
      {super.key,
        required this.textColor,
        required this.backgroundColor,
        required this.borderColor,
        required this.text,
        this.width,
        this.height,
        this.isIcon = false,
        this.icon,
        required this.onClicked});

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  Widget get buttonText {
    return Text(
      widget.text,
      style: TextStyle(
        color: widget.textColor,
        fontSize: 17.0,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked(),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: widget.borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor,
              blurRadius: 2.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.isIcon == false
            ? Center(child: buttonText)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.textColor,
            ),
            const SizedBox(
              width: 10.0,
            ),
            buttonText,
          ],
        ),
      ),
    );
  }
}

