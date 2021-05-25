import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/textfields/email_textfield.dart';
import 'package:beauty_fyi/container/textfields/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';
import 'package:beauty_fyi/container/landing_page/login_label.dart';
import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final signUpForm = GlobalKey<FormState>();

  final emailTextFieldController = TextEditingController();

  final firstNameTextFieldController = TextEditingController();

  final lastNameTextFieldController = TextEditingController();

  final passwordTextFieldController = TextEditingController();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  String? firstNameValue;
  String? lastNameValue;
  String? emailValue;
  String? passwordValue;
  bool disableTextFields = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(children: <Widget>[
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                        colorStyles['dark_purple']!,
                        colorStyles['light_purple']!,
                        colorStyles['blue']!,
                        colorStyles['green']!
                      ]))),
              Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 120.0,
                      ),
                      child: Form(
                          key: signUpForm,
                          autovalidateMode: autovalidateMode,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 30.0),
                              Text(
                                'Get started with Beauty-fyi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 30.0),
                              EmailTextField(
                                disableTextFields: disableTextFields,
                                emailTextFieldController:
                                    emailTextFieldController,
                                onSaved: (String? value) {
                                  emailValue = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              PasswordTextField(
                                  disableTextFields: disableTextFields,
                                  passwordTextFieldController:
                                      passwordTextFieldController,
                                  onSaved: (value) {
                                    passwordValue = value;
                                  }),
                              SizedBox(height: 10.0),
                              ActionButton(
                                  disableTextFields: disableTextFields,
                                  buttonText: "continue",
                                  form: signUpForm,
                                  onPressed: () {
                                    setState(() {
                                      autovalidateMode =
                                          AutovalidateMode.onUserInteraction;
                                      // disableTextFields = true;
                                    });
                                    signUpUser(
                                            emailValue:
                                                emailTextFieldController.text,
                                            passwordValue:
                                                passwordTextFieldController
                                                    .text,
                                            signUpForm: signUpForm,
                                            context: context)
                                        .then((value) => {
                                              setState(() {
                                                disableTextFields = false;
                                              })
                                            });
                                  }),
                              LoginLabel()
                            ],
                          ))))
            ])));
  }
}

Future signUpUser(
    {String? emailValue,
    String? passwordValue,
    required GlobalKey<FormState> signUpForm,
    required BuildContext context}) async {
  final storage = new FlutterSecureStorage();
  final HttpService http = HttpService();
  Navigator.pushNamed(context, '/onboarding-screen');

  if (!signUpForm.currentState!.validate()) {
    //return;
  }
  final content = new Map<String, dynamic>();
  content['email'] = emailValue;
  content['password'] = passwordValue;
  try {
    Response response = await http.postRequest(
        endPoint: 'authentication/register/1', data: content);

    if (response.statusCode == 200) {
      await storage.write(key: "key", value: response.data['key']);
      await storage.write(key: "email", value: content['email']);
      await storage.write(key: "password", value: content['password']);
      return;
    } else {
      // navigate to onboarding process
      Navigator.pushNamed(context, '/onboarding-screen');
      // Navigator.pushNamedAndRemoveUntil(
      // context, '/onboarding-screen', (route) => false);
      // throw response;
    }
  } catch (e) {
    print(e);
    MessageAlertDialog(
        message: "Unable to register, please try again.",
        context: context,
        onPressed: () => Navigator.of(context).pop()).show();
  }
}
