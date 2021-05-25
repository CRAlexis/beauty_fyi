import 'package:flutter/material.dart';

class LoadingAlertDialog {
  final String? message;
  final BuildContext? context;
  LoadingAlertDialog({this.message, this.context});

  Future<void> show() async {
    return showDialog(
        barrierDismissible: false,
        context: context!,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
                  height: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(message!),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          child: CircularProgressIndicator(),
                          height: 40,
                          width: 40,
                        )
                      ],
                    ),
                  )));
        });
  }

  pop() {
    Navigator.of(context!).pop();
  }
}
