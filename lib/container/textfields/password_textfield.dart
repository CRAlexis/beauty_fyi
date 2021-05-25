import 'package:beauty_fyi/styles/text.dart';
import 'package:beauty_fyi/styles/textfields.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController? passwordTextFieldController;
  final ValueSetter? onSaved;
  final bool? disableTextFields;
  PasswordTextField(
      {this.passwordTextFieldController, this.onSaved, this.disableTextFields});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '',
          style: textStyles['tf_label_white'],
        ),
        SizedBox(height: 00.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: textfieldStyles['blue_textfield'],
          height: 50.0,
          child: TextFormField(
            enabled: !disableTextFields!,
            onSaved: (newValue) {
              onSaved!(newValue);
            },
            validator: (value) {
              if (value.toString().isEmpty) {
                return "Please enter a password";
              }
              return null;
            },
            controller: passwordTextFieldController,
            obscureText: true,
            style: textStyles['tf_label'],
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Password',
              hintStyle: textStyles['tf_hint'],
            ),
          ),
        ),
      ],
    );
  }
}
