import 'dart:convert';

import 'package:beauty_fyi/container/textfields/email_textfield.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/container/textfields/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';
import 'package:beauty_fyi/container/landing_page/login_label.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
                          colors: [colorStyles['purple'], Colors.blue]))),
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
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OpenSans',
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DefaultTextField(
                                iconData: Icons.person,
                                hintText: "First name",
                                invalidMessage: "Invalid name",
                                labelText: "First name",
                                textInputType: TextInputType.name,
                                defaultTextFieldController:
                                    firstNameTextFieldController,
                                onSaved: (String value) {
                                  firstNameValue = value;
                                },
                                disableTextFields: disableTextFields,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              DefaultTextField(
                                iconData: Icons.person,
                                hintText: "Last name",
                                invalidMessage: "Invalid name",
                                labelText: "Last name",
                                textInputType: TextInputType.name,
                                defaultTextFieldController:
                                    lastNameTextFieldController,
                                onSaved: (String value) {
                                  lastNameValue = value;
                                },
                                disableTextFields: disableTextFields,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              EmailTextField(
                                disableTextFields: disableTextFields,
                                emailTextFieldController:
                                    emailTextFieldController,
                                onSaved: (String value) {
                                  emailValue = value;
                                },
                              ),
                              SizedBox(height: 20.0),
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
                                  buttonText: "Sign up",
                                  form: signUpForm,
                                  onPressed: () {
                                    setState(() {
                                      autovalidateMode =
                                          AutovalidateMode.onUserInteraction;
                                      disableTextFields = true;
                                    });
                                    signUpUser(
                                            firstNameTextFieldController.text,
                                            lastNameTextFieldController.text,
                                            emailTextFieldController.text,
                                            passwordTextFieldController.text,
                                            signUpForm,
                                            context)
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
    String firstNameValue,
    String lastNameValue,
    String emailValue,
    String passwordValue,
    GlobalKey<FormState> signUpForm,
    BuildContext context) async {
  if (!signUpForm.currentState.validate()) {
    //return;
  }
  final content = new Map<String, dynamic>();
  content['first_name'] = firstNameValue;
  content['last_name'] = lastNameValue;
  content['email'] = emailValue;
  content['password'] = passwordValue;
  try {
    final http.Response response = await http.post(
      // Uri.http('192.168.43.100:3333', 'sign-up'),
      Uri.parse("http://192.168.1.245:3333/sign-up"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTf-8',
        'Accept': 'application/json'
      },
      body: jsonEncode(content),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      //Go to dashboard
    } else {
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
    return;
  } catch (e) {
    print(e);
    return;
  }
}
