import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final GlobalKey<FormState>? form;
  final VoidCallback? onPressed;
  final String? buttonText;
  final bool? disableTextFields;
  ActionButton(
      {this.form, this.onPressed, this.buttonText, this.disableTextFields});
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
          onPressed!();
          if (!form!.currentState!.validate()) {
            //return false;
          }
        },
        // color: Colors.white,
        child: disableTextFields!
            ? SizedBox(
                child: CircularProgressIndicator(),
                height: 20,
                width: 20,
              )
            : Text(
                buttonText!,
                style: textStyles['button_label_blue'],
              ),
      ),
    );
  }
}

void popDialouge() {}
