import 'package:flutter/material.dart';

class MessageAlertDialog {
  final String? message;
  final BuildContext? context;
  final VoidCallback? onPressed;
  final bool dismissible;
  MessageAlertDialog(
      {this.message, this.context, this.onPressed, this.dismissible = true});

  Future<void> show() {
    return showDialog(
        barrierDismissible: dismissible,
        context: context!,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              padding: EdgeInsets.all(0),
              child: Text(message!),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    onPressed!();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  pop() {
    Navigator.of(context!).pop();
  }
}
