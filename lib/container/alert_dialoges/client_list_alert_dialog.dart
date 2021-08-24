import 'dart:async';

import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ClientListAlertDialog {
  final onConfirm;
  final BuildContext? context;
  ClientListAlertDialog({this.onConfirm, this.context}) {
    clients = ClientModel().readClients();
  }
  Future<List<ClientModel>>? clients;

  Future<String?> show() async {
    String? clientId;
    return await showDialog(
        barrierDismissible: true,
        context: context!,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Stack(children: [
                  Container(
                      child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "choose a client",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FutureBuilder<List<ClientModel>>(
                            future: clients,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  padding: EdgeInsets.only(bottom: 40),
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          setState(() => clientId !=
                                                  snapshot.data![index].id
                                              ? clientId = snapshot
                                                  .data![index].id as String
                                              : clientId = null);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: clientId ==
                                                        snapshot.data![index].id
                                                    ? colorStyles['green']
                                                    : Colors.white),
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                  "${snapshot.data![index].clientFirstName} ${snapshot.data![index].clientLastName}"),
                                            )));
                                  },
                                );
                              }
                              Timer(Duration(seconds: 1), () {
                                setState(() {});
                              });
                              return Container();
                            }),
                      ],
                    ),
                  )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(1),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(15.0)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          Navigator.of(context).pop(clientId);
                        },
                        child: Text(
                          clientId != null ? "confirm" : "",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ),
                    ),
                  )
                ]);
              }));
        });
  }

  pop() {
    Navigator.of(context!).pop();
  }
}
