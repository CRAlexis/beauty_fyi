import 'package:flutter/material.dart';

class AreYouSureAlertDialog {
  final String message;
  final String leftButtonText;
  final String rightButtonText;
  final onLeftButton;
  final onRightButton;
  final BuildContext context;
  final bool dismissible;
  const AreYouSureAlertDialog(
      {Key key,
      this.message,
      this.leftButtonText,
      this.rightButtonText,
      this.onLeftButton,
      this.onRightButton,
      this.context,
      this.dismissible = false});

  Future<void> show() async {
    return showDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                  child: Text(leftButtonText),
                  onPressed: () {
                    onLeftButton();
                  }),
              TextButton(
                  child: Text(rightButtonText),
                  onPressed: () {
                    onRightButton();
                  }),
            ],
          );
        });
  }

  pop() {
    Navigator.of(context).pop();
  }
}
