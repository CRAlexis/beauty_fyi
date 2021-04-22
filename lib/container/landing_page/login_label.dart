import 'package:flutter/material.dart';

class LoginLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/");
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "Already have an account? ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
        ));
  }
}
