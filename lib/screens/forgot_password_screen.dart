import 'package:beauty_fyi/container/textfields/email_textfield.dart';

import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailTextFieldController = TextEditingController();
  String? emailValue;
  GlobalKey<FormState>? resetPasswordForm;
  bool disableTextFields = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: false
            ? AppBar(
                title: Text("beauty-fyi"),
              )
            : null,
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
                          colors: [colorStyles['purple']!, Colors.blue]))),
              Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 120.0,
                      ),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Form(
                              key: resetPasswordForm,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Reset password',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'OpenSans',
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  EmailTextField(
                                    disableTextFields: disableTextFields,
                                    emailTextFieldController:
                                        emailTextFieldController,
                                    onSaved: (String? value) {
                                      emailValue = value;
                                    },
                                  ),
                                  ActionButton(
                                    buttonText: "Reset password",
                                    onPressed: () {},
                                    disableTextFields: disableTextFields,
                                  ),
                                ],
                              )))))
            ])));
  }
}
