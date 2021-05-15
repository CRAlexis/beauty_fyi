import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/client_list_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/view_service/image_and_name_card.dart';
import 'package:beauty_fyi/container/view_service/start_session_button.dart';
import 'package:beauty_fyi/container/view_service/tab_card.dart';
import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';

class ViewServiceScreen extends StatefulWidget {
  final args;
  const ViewServiceScreen({Key key, this.args}) : super(key: key);
  @override
  _ViewServiceScreenState createState() => _ViewServiceScreenState();
}

class _ViewServiceScreenState extends State<ViewServiceScreen> {
  Future service;
  String serviceName;
  @override
  void initState() {
    super.initState();
    service = fetchService(id: widget.args['id']);
  }

  void refreshFuture() {
    service = fetchService(id: widget.args['id']);
  }

  void newSession({SessionModel sessionModel}) async {
    final result =
        await ClientListAlertDialog(context: context, onConfirm: () {}).show();
    if (result != null) {
      print(result.values.first);
      await DateTimeModel(className: 'countdown').removeDateTime();
      sessionModel.setClientId = result.values.first;
      int sessionId = await sessionModel.startSession(sessionModel);
      sessionModel.setSessionId = sessionId;
      Navigator.pushNamed(context, "/live-session", arguments: {
        'sessionModel': sessionModel,
      });
    }
  }

  void navigateToSessionPage() async {
    try {
      print("args ${widget.args['id']}");

      SessionModel sessionModel = SessionModel(
          clientId: null,
          serviceId: widget.args['id'],
          dateTime: DateTime.now(),
          notes: "",
          active: true,
          currentProcess: 0);
      List sessionAlreadyActive = await sessionModel.sessionInit();

      if (sessionAlreadyActive[0]) {
        AreYouSureAlertDialog(
          dismissible: true,
          context: context,
          message:
              "You already have a session active with ${sessionAlreadyActive[1]}.",
          leftButtonText: "New session",
          rightButtonText: "Resume",
          onLeftButton: () async {
            Navigator.of(context).pop();
            newSession(sessionModel: sessionModel);
          },
          onRightButton: () async {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/live-session",
                arguments: {'sessionModel': sessionAlreadyActive[3]});
          },
        ).show();
      } else {
        newSession(sessionModel: sessionModel);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          focused: true,
          transparent: false,
          titleText: serviceName != null ? serviceName : "Beauty-fyi",
          leftIcon: Icons.arrow_back,
          rightIcon: Icons.more_vert,
          leftIconClicked: () {
            Navigator.of(context).pop();
          },
          rightIconClicked: () {},
          automaticallyImplyLeading: false,
          centerTitle: false,
        ),
        body: FutureBuilder(
            future: service,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                serviceName = snapshot.data['service_name'];
                return Stack(
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
                                serviceId: widget.args['id'],
                              ),
                              SizedBox(
                                height: 100,
                              ),
                            ]))),
                    StartSessionButton(
                      onPressed: () {
                        navigateToSessionPage();
                      },
                    )
                  ],
                );
              } else {
                return Text(
                    ""); // probably error message, then return them back to homescreen
              }
            }));
  }
}

Future<Map<String, dynamic>> fetchService({id}) async {
  final serviceModel = new ServiceModel(id: id);
  print("refreshing future");
  return await serviceModel.readService();
}
