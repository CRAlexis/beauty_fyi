import 'package:beauty_fyi/styles/text.dart';
import 'package:beauty_fyi/styles/textfields.dart';
import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController? emailTextFieldController;
  final ValueSetter<String?>? onSaved;
  final bool? disableTextFields;
  EmailTextField(
      {this.emailTextFieldController, this.onSaved, this.disableTextFields});

  @override
  Widget build(BuildContext context) {
    String validationErrorMessage = "Email not valid";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Text(
            '',
            style: textStyles['tf_label_white'],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: textfieldStyles['blue_textfield'],
          height: 50.0,
          child: TextFormField(
            enabled: !disableTextFields!,
            keyboardType: TextInputType.emailAddress,
            controller: emailTextFieldController,
            onSaved: (newValue) {
              onSaved!(newValue);
            },
            onChanged: (value) {},
            validator: (value) {
              String email = value.toString().trim();
              if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email)) {
                return validationErrorMessage;
              }
              return null;
            },
            style: textStyles['tf_label'],
            decoration: InputDecoration(
                errorStyle: TextStyle(),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                  size: double.parse('30'),
                ),
                hintText: 'Email',
                hintStyle: textStyles['tf_hint']),
          ),
        ),
      ],
    );
  }
}
