import 'package:flutter/material.dart';

class SignUpLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: "Dont have an account? ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: "Sign up",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ),
    );
  }
}
