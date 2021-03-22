import 'package:beauty_fyi/styles/text.dart';
import 'package:beauty_fyi/styles/textfields.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController _passwordTextField;
  PasswordTextField(this._passwordTextField);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: textStyles['tf_label'],
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: textfieldStyles['fullwidth_textfield'],
          height: 50.0,
          child: TextFormField(
            controller: _passwordTextField,
            obscureText: true,
            style: textStyles['tf_label'],
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: textStyles['tf_hint'],
            ),
          ),
        ),
      ],
    );
  }
}
