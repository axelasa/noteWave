import 'package:flutter/material.dart';
import 'package:note_wave/pages/authentication/signin.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_color.dart';
import '../../common/widgets/app_font.dart';
import '../../common/widgets/app_input.dart';
import '../../common/widgets/screen_title.dart';
import '../../constants/constant_asset.dart';
import '../../service/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController aliasController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool shouldShowAlert = false;
  bool shouldShowError = true;
  String alertMessage = '';


  final AuthService _auth = AuthService();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:  EdgeInsets.all(15.0),
                child:  Center(
                  child: ScreenTitle(
                    title: 'Register',
                  ),
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
              const SizedBox(
                height: 10,
              ),
              shouldShowAlert
                  ? shouldShowError
                  ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.2),
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
                    color: AppColors.successColor.withOpacity(0.2),
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
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 15,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      AppInput(
                        label: 'Email',
                        type: TextInputType.text,
                        controller: emailController,
                        validator: (val) => val!.isEmpty
                            ? '*You must provide your email address'
                            : null,
                        onChanged: (val) {
                          emailController.text = val;
                        },),
                      const SizedBox(
                        height: 15,
                      ),
                      AppInput(
                        label: 'First Name',
                        type: TextInputType.text,
                        controller: firstNameController,
                        validator: (val) => val!.isEmpty
                            ? '*You must provide your first Name'
                            : null,
                        onChanged: (val) {
                          firstNameController.text = val;
                        },),
                      const SizedBox(
                        height: 15,
                      ),
                      AppInput(
                        label: 'Last Name',
                        type: TextInputType.text,
                        controller: lastNameController,
                        validator: (val) => val!.isEmpty
                            ? '*You must provide your last Name'
                            : null,
                        onChanged: (val) {
                          lastNameController.text = val;
                        },),
                      const SizedBox(
                        height: 15,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AppInput(
                        label: 'password',
                        type: TextInputType.text,
                        controller: passwordController,
                        validator: (val) => val!.length < 6
                            ? '*password cannot be empty'
                            : null,
                        onChanged: (val) {
                          passwordController.text = val;
                        },),
                      const SizedBox(
                        height: 15,
                      ),
                      AppButton(
                        textColor: Colors.white,
                        backgroundColor: AppColors.mainColor,
                        borderColor: AppColors.secondaryColor,
                        text: 'Register',
                        onClicked: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
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
                              _navigateToSignInPage();
                            },
                            child: const Text(
                              'Sign In',
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
                      ),
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

  _register() async {
    String resp = await _auth.registerUser(
      email: emailController.text,
      name: '${firstNameController.text} ${lastNameController.text}',
      password: passwordController.text
    );
    if (resp == 'Successfully registered') {
      giveSuccessMessage(message: "Successfully registered");
      Future.delayed(const Duration(seconds: 2), () async {
        _navigateToSignInPage();
      });
    } else {
      giveErrorMessage(message: resp);
    }
  }


  _navigateToSignInPage() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/signin', (route) => false);
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
