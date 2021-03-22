import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final GlobalKey<FormState> loginForm;
  LoginButton({this.loginForm});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
            padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            backgroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () {
          print(loginForm.currentState.validate());
        },
        // color: Colors.white,
        child: Text(
          'LOGIN',
          style: textStyles['button_label_blue'],
        ),
      ),
    );
  }
}
