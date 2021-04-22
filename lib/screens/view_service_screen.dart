import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/view_service/image_and_name_card.dart';
import 'package:beauty_fyi/container/view_service/start_session_button.dart';
import 'package:beauty_fyi/container/view_service/tab_card.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:flutter/material.dart';

class ViewServiceScreen extends StatefulWidget {
  final args;
  const ViewServiceScreen({Key key, this.args}) : super(key: key);
  @override
  _ViewServiceScreenState createState() => _ViewServiceScreenState();
}

class _ViewServiceScreenState extends State<ViewServiceScreen> {
  Future service;
  @override
  void initState() {
    super.initState();
    service = fetchService(id: widget.args['id']);
  }

  void refreshFuture() {
    service = fetchService(id: widget.args['id']);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: service,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
              appBar: CustomAppBar(
                focused: true,
                transparent: false,
                titleText: snapshot.data['service_name'],
                leftIcon: Icons.arrow_back,
                rightIcon: null,
                leftIconClicked: () {
                  Navigator.of(context).pop();
                },
                rightIconClicked: () {},
                automaticallyImplyLeading: false,
                centerTitle: false,
              ),
              body: Stack(
                children: [
                  Container(
                      height: double.infinity,
                      child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 20.0,
                          ),
                          child: Column(children: [
                            ImageAndNameCard(
                                serviceImage:
                                    File(snapshot.data['service_image']),
                                serviceName: snapshot.data['service_name'],
                                onEdit: () {
                                  Navigator.pushNamed(context, "/add-service",
                                      arguments: {
                                        'id': snapshot.data['id']
                                      }).then((value) {
                                    refreshFuture();
                                  });
                                },
                                onDelete: () async {
                                  AreYouSureAlertDialog(
                                    context: context,
                                    message:
                                        "Are you sure you want to delete this service?",
                                    leftButtonText: "no",
                                    rightButtonText: "yes",
                                    onLeftButton: () {
                                      Navigator.of(context).pop();
                                    },
                                    onRightButton: () async {
                                      try {
                                        await ServiceModel(
                                                id: snapshot.data['id'])
                                            .deleteService();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        print(e);
                                        MessageAlertDialog(
                                            context: context,
                                            message:
                                                "Unable to delete this service.",
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            });
                                      }
                                    },
                                  ).show();
                                }),
                            TabCard(
                              serviceDescription:
                                  snapshot.data['service_description'],
                            ),
                            SizedBox(
                              height: 100,
                            ),
                          ]))),
                  StartSessionButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/live-session",
                          arguments: ({'service_id': widget.args['id']}));
                    },
                  )
                ],
              ));
        } else {
          return Text(
              ""); // probably error message, then return them back to homescreen
        }
      },
    );
  }
}

Future<Map<String, dynamic>> fetchService({id}) async {
  final serviceModel = new ServiceModel(id: id);
  print("refreshing future");
  return await serviceModel.readService();
}
