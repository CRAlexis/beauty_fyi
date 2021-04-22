import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ForgotPasswordLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, "/forgot-password");
        },
        child: Text(
          "forgot password?",
          style: textStyles['tf_label'],
        ),
      ),
    );
  }
}
