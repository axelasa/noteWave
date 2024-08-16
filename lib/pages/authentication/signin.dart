import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:note_wave/constants/constant_asset.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_color.dart';
import '../../common/widgets/app_font.dart';
import '../../common/widgets/app_input.dart';
import '../../common/widgets/app_password_input.dart';
import '../../common/widgets/screen_title.dart';
import '../../home.dart';
import '../../service/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  String email = '';
  String password = '';

  bool shouldShowAlert = false;
  bool shouldShowError = true;
  String alertMessage = '';

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: ScreenTitle(title: 'Note Wave '),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Image(
                    image: AssetImage(diary),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: ScreenTitle(title: 'SignIn'),
              ),
              shouldShowAlert
                  ? shouldShowError
                  ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                  AppColors.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alertMessage,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                      fontFamily: AppFont.font,
                      fontWeight: FontWeight.w500),
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.successColor
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  alertMessage,
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontFamily: AppFont.font,
                      fontWeight: FontWeight.w500),
                ),
              )
                  : const SizedBox(),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 8,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: AppInput(
                          label: 'email',
                          type: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (val) =>
                          val!.isEmpty ? 'Enter an Email' : null,
                          onChanged: (val) {
                            emailController.text = val;
                            email = val;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AppPasswordInput(
                          label: 'password',
                          type: TextInputType.text,
                          controller: passwordController,
                          validator: (val) => val!.isEmpty
                              ? 'Enter a password 6+ chars long'
                              : null,
                          onChanged: (val) {
                            passwordController.text = val;
                            password = val;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AppButton(
                          textColor: Colors.white,
                          backgroundColor: AppColors.mainColor,
                          borderColor: AppColors.mainColor,
                          text: 'SignIn',
                          onClicked: () async{
                            if (_formKey.currentState!.validate()) {
                              const CircularProgressIndicator();
                              await loginUser();
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontFamily: AppFont.font,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/signup', (route) => false);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontFamily: AppFont.font,
                                  color: AppColors.secondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  _forgotPassword(){
    Navigator.of(context).pushNamed('/forgot_password');
  }

  Future<void> loginUser() async {
    String resp = await _auth.signInUser(email: email, password: password);
    if(resp == 'Success') {
      giveSuccessMessage(message: 'Success');
      Future.delayed(const Duration(seconds: 2),()async{
        _navigateToHomeScreen();
      });
    }else{
      giveErrorMessage(message: resp);
    }
  }

  _navigateToHomeScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }


  void giveErrorMessage({required String message}) {
    setState(() {
      shouldShowAlert = true;
      shouldShowError = true;
      alertMessage = message;
      Future.delayed(const Duration(milliseconds: 1000));
    });
  }

  void giveSuccessMessage({required String message}) {
    setState(() {
      shouldShowAlert = true;
      shouldShowError = false;
      alertMessage = message;
      Future.delayed(const Duration(milliseconds: 1000));
    });
  }

}
