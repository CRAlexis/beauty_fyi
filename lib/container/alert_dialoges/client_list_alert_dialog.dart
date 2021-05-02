import 'dart:async';

import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:beauty_fyi/styles/text.dart';
import 'package:flutter/material.dart';

class ClientListAlertDialog {
  final onConfirm;
  final BuildContext context;
  ClientListAlertDialog({this.onConfirm, this.context}) {
    clients = ClientModel().readClients();
  }
  Future<List<ClientModel>> clients;

  Future<Map<String, int>> show() async {
    int indexFocused;
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    constraints: BoxConstraints(maxHeight: double.infinity),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder<List<ClientModel>>(
                            future: clients,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        print("here");
                                        setState(() => indexFocused !=
                                                snapshot.data[index].clientId
                                            ? indexFocused =
                                                snapshot.data[index].clientId
                                            : indexFocused = null);
                                        print("$indexFocused, $index");
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: indexFocused ==
                                                      snapshot
                                                          .data[index].clientId
                                                  ? colorStyles['green']
                                                  : Colors.white),
                                          child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                  "${snapshot.data[index].clientName}"))),
                                    );
                                  },
                                );
                              }
                              Timer(Duration(seconds: 1), () {
                                setState(() {});
                              });
                              return Container();
                            }),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(15.0)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop({'clientId': indexFocused});
                            },
                            child: Text(
                              indexFocused != null ? "confirm" : "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              }));
        });
  }

  pop() {
    Navigator.of(context).pop();
  }
}
