import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';


  showSnackBar({
    required BuildContext context,
    required String message,
    required String title,
    required ContentType contentType
  }){
    final SnackBar snackBar = SnackBar(
      elevation: 2,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
