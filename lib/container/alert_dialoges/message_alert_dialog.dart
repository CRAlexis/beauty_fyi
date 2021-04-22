import 'package:flutter/material.dart';

class MessageAlertDialog {
  final String message;
  final BuildContext context;
  final VoidCallback onPressed;
  MessageAlertDialog({this.message, this.context, this.onPressed});

  Future<void> show() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              padding: EdgeInsets.all(0),
              child: Text(message),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    onPressed();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }
}