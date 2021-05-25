import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class StartSessionButton extends StatelessWidget {
  final onPressed;
  StartSessionButton({this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
                elevation: MaterialStateProperty.all(10),
                padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
                backgroundColor:
                    MaterialStateProperty.all(colorStyles['green'])),
            onPressed: () => onPressed(),
            child: Text(
              "Start or resume session",
              style: textStyles['button_label_white'],
            ),
          ),
        ));
  }
}
