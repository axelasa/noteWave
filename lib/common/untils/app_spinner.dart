import 'package:flutter/material.dart';
import '../widgets/app_color.dart';

class AppSpinner extends StatelessWidget {
  final double stroke;
  const AppSpinner({super.key, required this.stroke});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: AppColors.mainColor,
      strokeWidth: stroke,
    );
  }
}
