import 'dart:async';

import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/providers/clients_provider.dart';
import 'package:beauty_fyi/screens/client_screen.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientNotifierProvider = StateNotifierProvider(
    (ref) => ClientsNotifier(ClientProviderEnums.READALL, 0));

class ClientsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderListener(
        onChange: (BuildContext context, state) {
          if (state is ClientsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  duration: Duration(minutes: 2),
                  action: SnackBarAction(
                      label: "refresh",
                      onPressed: () => context
                          .read(clientNotifierProvider.notifier)
                          .getClients())),
            );
          }
        },
        provider: clientNotifierProvider,
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  // colorStyles['blue'],
                  colorStyles['cream']!,
                  colorStyles['cream']!,
                ])),
            height: double.infinity,
            child: Stack(children: [
              Consumer(
                builder: (context, watch, child) {
                  final clientProviderController =
                      watch(clientNotifierProvider.notifier);
                  final state = watch(clientNotifierProvider);

                  if (state is ClientsInitial) {
                    return Container();
                  } else if (state is ClientsLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ClientsLoaded) {
                    if (state.clients.length == 0) {
                      return Center(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/add-client-screen');
                            },
                            child: Text("Get started by adding a client.")),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: state.clients.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, '/client-screen',
                                  arguments: {'id': state.clients[index].id}),
                              child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          CircleAvatar(
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                            backgroundColor:
                                                Colors.grey.shade100,
                                            backgroundImage: File(state
                                                        .clients[index]
                                                        .clientImage!
                                                        .path)
                                                    .existsSync()
                                                ? FileImage(state.clients[index]
                                                    .clientImage!)
                                                : null,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    20),
                                            child: Text(
                                              "${state.clients[index].clientFirstName} ${state.clients[index].clientLastName}",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          40),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 00,
                                      ),
                                    ],
                                  )));
                        });
                  } else {
                    return Container();
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: FloatingActionButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-client-screen')
                              .then((value) {
                            context
                                .read(clientNotifierProvider.notifier)
                                .getClients();
                          });
                        },
                        backgroundColor: colorStyles['blue'],
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ))),
              )
            ])));
  }
}
