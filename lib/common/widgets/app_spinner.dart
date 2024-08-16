import 'package:flutter/material.dart';

import 'app_color.dart';

class AppSpinner extends StatelessWidget {
  final double stroke;
  const AppSpinner({Key? key, required this.stroke}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: AppColors.mainColor,
      strokeWidth: stroke,
    );
  }
}
