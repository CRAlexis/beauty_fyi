import 'package:beauty_fyi/container/landing_page/email_textfield.dart';
import 'package:beauty_fyi/container/landing_page/forgot_password_label.dart';
import 'package:beauty_fyi/container/landing_page/login_button.dart';
import 'package:beauty_fyi/container/landing_page/password_textfield.dart';
import 'package:beauty_fyi/container/landing_page/sign_up_label.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final loginForm = GlobalKey<FormState>();
  final emailTextField = TextEditingController();
  final passwordTextField = TextEditingController();
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
                          key: loginForm,
                          autovalidateMode: AutovalidateMode.disabled,
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
                                emailTextField: emailTextField,
                                myCallBack: (value) {},
                              ),
                              SizedBox(height: 10.0),
                              PasswordTextField(passwordTextField),
                              ForgotPasswordLabel(),
                              SizedBox(height: 10.0),
                              LoginButton(loginForm: loginForm),
                              SignUpLabel()
                            ],
                          ))))
            ])));
  }
}
