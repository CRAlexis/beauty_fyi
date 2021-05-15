import 'dart:async';

import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ClientsTab extends StatefulWidget {
  @override
  _ClientsTabState createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  Future<List<ClientModel>> clients;

  void initState() {
    super.initState();
    fetchFuture();
  }

  void fetchFuture() async {
    clients = fetchClients();
  }

  void refreshFuture() async {
    setState(() {
      clients = fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                // colorStyles['blue'],
                colorStyles['cream'],
                colorStyles['cream'],
              ]))),
      Container(
          height: double.infinity,
          child: Stack(children: [
            FutureBuilder<List<ClientModel>>(
                future: clients,
                builder: (context, clients) {
                  print("client page should have updated");
                  if (!clients.hasData) {
                    Timer refreshTimer;
                    refreshTimer = Timer(Duration(milliseconds: 500), () {
                      refreshTimer.cancel();
                      refreshFuture();
                    });
                    return Align(
                      alignment: Alignment.center,
                      child: Text("No clients founds"),
                    );
                  }
                  if (clients.data.length == 0) {
                    return Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/add-client-screen')
                                .then((value) {
                              refreshFuture();
                            });
                          },
                          child: Text("Get started by adding a client.")),
                    );
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: clients.data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                    context, '/client-screen', arguments: {
                                  'clientId': clients.data[index].id,
                                  'clientName':
                                      "${clients.data[index].clientFirstName}",
                                  'clientImage':
                                      clients.data[index].clientImage,
                                }),
                            child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey.shade100,
                                          backgroundImage: File(clients
                                                      .data[index]
                                                      .clientImage
                                                      .path)
                                                  .existsSync()
                                              ? FileImage(clients
                                                  .data[index].clientImage)
                                              : null,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          "${clients.data[index].clientFirstName} ${clients.data[index].clientLastName}",
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Divider(
                                          height: 0.5,
                                          color: Colors.black12,
                                        )),
                                    SizedBox(
                                      height: 00,
                                    ),
                                  ],
                                )));
                      });
                }),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add-client-screen')
                            .then((value) {
                          refreshFuture();
                        });
                      },
                      backgroundColor: colorStyles['light_purple'],
                      child: Icon(
                        Icons.add,
                        size: 40,
                      ))),
            )
          ])),
    ]);
  }
}

Future<List<ClientModel>> fetchClients() async {
  return await ClientModel().readClients();
}
