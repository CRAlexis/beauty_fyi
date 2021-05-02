import 'dart:convert';

import 'package:beauty_fyi/container/textfields/email_textfield.dart';
import 'package:beauty_fyi/container/textfields/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';
import 'package:beauty_fyi/container/landing_page/login_label.dart';
import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
  String firstNameValue;
  String lastNameValue;
  String emailValue;
  String passwordValue;
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
                        colorStyles['dark_purple'],
                        colorStyles['light_purple'],
                        colorStyles['blue'],
                        colorStyles['green']
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
                                onSaved: (String value) {
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
    {String emailValue,
    String passwordValue,
    GlobalKey<FormState> signUpForm,
    BuildContext context}) async {
  HttpService http = HttpService();

  if (!signUpForm.currentState.validate()) {
    //return;
  }
  final content = new Map<String, dynamic>();
  content['email'] = emailValue;
  content['password'] = passwordValue;
  try {
    Response response = await http.postRequest(
        endPoint: 'authentication/register/1', data: content);
    if (response.statusCode == 200) {
      print(response.data['key']);
      final storage = new FlutterSecureStorage();
      return;
    } else {
      throw response;
    }
  } catch (e) {
    print(e);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Unable to sign up. Please try again."),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("ok"))
            ],
          );
        });
  }
}
