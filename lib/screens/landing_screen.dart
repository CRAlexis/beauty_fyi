import 'package:beauty_fyi/container/textfields/email_textfield.dart';
import 'package:beauty_fyi/container/landing_page/action_button.dart';
import 'package:beauty_fyi/container/textfields/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/sign_up_label.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final loginForm = GlobalKey<FormState>();
  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final bool disableTextFields = false;
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
                          key: loginForm,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Sign In',
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
                                onSaved: (String? value) {},
                              ),
                              SizedBox(height: 10.0),
                              PasswordTextField(
                                  disableTextFields: disableTextFields,
                                  passwordTextFieldController:
                                      passwordTextFieldController,
                                  onSaved: (value) {}),
                              // ForgotPasswordLabel(),
                              SizedBox(height: 10.0),
                              ActionButton(
                                buttonText: "login in",
                                onPressed: () {},
                                disableTextFields: disableTextFields,
                              ),
                              SignUpLabel()
                            ],
                          ))))
            ])));
  }
}
