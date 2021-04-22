import 'dart:async';

import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isLoading;
  final String backgroundColor;
  ActionButton({
    this.onPressed,
    this.buttonText,
    this.isLoading,
    this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            backgroundColor:
                MaterialStateProperty.all(colorStyles[backgroundColor])),
        onPressed: () {
          onPressed();
        },
        // color: Colors.white,
        child: isLoading
            ? SizedBox(
                child: CircularProgressIndicator(),
                height: 20,
                width: 20,
              )
            : Text(
                buttonText,
                style: textStyles['button_label_white'],
              ),
      ),
    );
  }
}
