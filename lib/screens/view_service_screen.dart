import 'dart:developer';
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
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ViewServiceScreen extends StatefulWidget {
  final args;
  const ViewServiceScreen({Key? key, this.args}) : super(key: key);
  @override
  _ViewServiceScreenState createState() => _ViewServiceScreenState();
}

class _ViewServiceScreenState extends State<ViewServiceScreen> {
  late final ServiceModel serviceModel;
  String? serviceName;
  ScrollController _pageScrollController = ScrollController();
  double elevation = 0;
  @override
  void initState() {
    super.initState();
    // service = fetchService(id: widget.args['id']);
    serviceModel = widget.args['sessionModel'];
    _pageScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _pageScrollController.dispose();
  }

  _scrollListener() {
    if (_pageScrollController.position.pixels > 50) {
      setState(() {
        elevation = 20;
      });
    } else {
      setState(() {
        elevation = 0;
      });
    }
  }

  void newSession({required SessionModel sessionModel}) async {
    final result =
        await ClientListAlertDialog(context: context, onConfirm: () {}).show();
    if (result?.values.first != null) {
      print("result $result");
      print(result?.values.first);
      await DateTimeModel(className: 'countdown').removeDateTime();
      sessionModel.setClientId = result?.values.first as int;
      int sessionId = await sessionModel.startSession(sessionModel);
      sessionModel.setSessionId = sessionId;
      Navigator.pushNamed(context, "/live-session", arguments: {
        'sessionModel': sessionModel,
      });
    }
  }

  void navigateToSessionPage() async {
    try {
      SessionModel sessionModel = SessionModel(
          clientId: null,
          serviceId: serviceModel.id,
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
          titleText: serviceModel.serviceName,
          leftIcon: Icons.arrow_back,
          rightIcon: Icons.more_vert,
          leftIconClicked: () {
            Navigator.of(context).pop();
          },
          rightIconClicked: () {},
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: elevation,
        ),
        body: Stack(
          children: [
            Container(
                height: double.infinity,
                child: SingleChildScrollView(
                    controller: _pageScrollController,
                    physics: ScrollPhysics(),
                    child: Column(children: [
                      _serviceScreenHeader(
                          context: context, serviceData: serviceModel),
                      TabCard(
                        serviceDescription:
                            serviceModel.serviceDescription as String,
                        serviceId: serviceModel.id as int,
                      ),
                    ]))),
            StartSessionButton(
              onPressed: () {
                navigateToSessionPage();
              },
            )
          ],
        ));
  }
}

Widget _serviceScreenHeader(
    {required BuildContext context, required ServiceModel serviceData}) {
  File serviceImage = serviceData.imageSrc as File;
  return Stack(
    alignment: Alignment.topCenter,
    children: [
      Container(
        height: MediaQuery.of(context).size.height / 7,
        color: colorStyles['blue'],
      ),
      Container(
          padding: EdgeInsets.only(top: 0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height / 8),
              ),
              elevation: 5,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height / 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height / 9,
                  backgroundColor: colorStyles['blue'],
                  backgroundImage: serviceImage.existsSync()
                      ? FileImage(serviceImage)
                      : null,
                ),
              ))),
    ],
  );
}

/*
ImageAndNameCard(
                                  serviceImage: serviceData.imageSrc,
                                  serviceName: serviceData.serviceName,
                                  onEdit: () {
                                    Navigator.pushNamed(context, "/add-service",
                                            arguments: {'id': serviceData.id})
                                        .then((value) {
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
                                          await ServiceModel(id: serviceData.id)
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

                                  
                              SizedBox(
                                height: 100,
                              ),
*/
