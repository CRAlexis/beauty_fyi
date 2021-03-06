import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? buttonText;
  final bool? isLoading;
  final String? backgroundColor;
  final IconData? iconData;
  ActionButton(
      {this.onPressed,
      this.buttonText,
      this.isLoading,
      this.backgroundColor,
      this.iconData});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(EdgeInsets.all(5.0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            backgroundColor:
                MaterialStateProperty.all(colorStyles[backgroundColor!])),
        onPressed: () {
          onPressed!();
        },
        // color: Colors.white,
        child: isLoading!
            ? SizedBox(
                child: CircularProgressIndicator(),
                height: 20,
                width: 20,
              )
            : iconData != null
                ? Icon(
                    iconData,
                    size: 30,
                  )
                : Text(
                    buttonText!,
                    style: textStyles['button_label_white'],
                  ),
      ),
    );
  }
}
