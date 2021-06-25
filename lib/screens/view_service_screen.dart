import 'dart:convert';
import 'dart:io';

import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/media/grid_media.dart';
import 'package:beauty_fyi/container/view_service/start_session_button.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:beauty_fyi/providers/sessions_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:beauty_fyi/extensions/string_extension.dart';

final serviceNotifierProvider = StateNotifierProvider.autoDispose
    .family<ServicesNotifier, ServicesState, int>((ref, params) =>
        ServicesNotifier(ServicesProviderEnum.READONE, params));
final sessionNotifierProvider = StateNotifierProvider(
    (ref) => SessionsNotifier(SessionProviderEnums.NULL, null));

class ViewServiceScreen extends ConsumerWidget {
  final args;
  ViewServiceScreen({Key? key, this.args}) : super(key: key);

  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(serviceNotifierProvider(args['serviceId']));
    return Scaffold(
        appBar: CustomAppBar(
          focused: true,
          transparent: false,
          titleText: state is ServiceLoaded ? state.service.serviceName : "",
          leftIcon: Icons.arrow_back,
          leftIconClicked: () {
            Navigator.of(context).pop();
          },
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          showMenuIcon: true,
          menuOptions: ['edit', 'delete'],
          menuIconClicked: (String val) {
            switch (val) {
              case 'edit':
                state is ServiceLoaded
                    ? Navigator.pushNamed(context, "/add-service",
                        arguments: {'id': state.service.id})
                    : null;
                break;
              case 'delete':
                print("needs to be impletemented");
                break;
            }
          },
        ),
        body: Stack(
          children: [
            Container(
                // child: SingleChildScrollView(
                // physics: ScrollPhysics(),
                child: Column(children: [
              _serviceScreenHeader(context: context, state: state),
              _TabBody(
                serviceModel: state is ServiceLoaded ? state.service : null,
                serviceMedia: state is ServiceLoaded ? state.serviceMedia : [],
              )
            ])),
            StartSessionButton(
              onPressed: () {
                state is ServiceLoaded
                    ? context
                        .read(sessionNotifierProvider.notifier)
                        .newSession(state.service.id as int, context)
                    : null;
              },
            )
          ],
        ));
  }
}

Widget _serviceScreenHeader(
    {required BuildContext context, required ServicesState state}) {
  final File imageFile =
      state is ServiceLoaded ? state.service.imageSrc as File : new File("");
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
                child: state is ServiceLoaded
                    ? CircleAvatar(
                        radius: MediaQuery.of(context).size.height / 9,
                        backgroundColor: colorStyles['blue'],
                        backgroundImage: imageFile.existsSync()
                            ? FileImage(imageFile)
                            : null,
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ))),
    ],
  );
}

class _TabBody extends StatefulWidget {
  final ServiceModel? serviceModel;
  final List<ServiceMedia> serviceMedia;
  const _TabBody({Key? key, this.serviceModel, required this.serviceMedia})
      : super(key: key);

  @override
  __TabBodyState createState() => __TabBodyState();
}

class __TabBodyState extends State<_TabBody>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        child: TabBar(
            controller: tabController,
            labelColor: Colors.black,
            indicatorColor: colorStyles['green'],
            tabs: [
              Tab(
                icon: Icon(Icons.info_outline),
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
              ),
              Tab(
                // text: "Media",
                icon: Icon(Icons.image),
              ),
            ]),
      ),
      Expanded(
        child: Container(
          // height: 400,
          child: widget.serviceModel != null
              ? TabBarView(controller: tabController, children: [
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                  fontSize: 16),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(widget.serviceModel?.serviceDescription
                                as String),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "Processes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                  fontSize: 16),
                            ),
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: (jsonDecode(widget.serviceModel
                                        ?.serviceProcesses as String) as List)
                                    .length,
                                itemBuilder: (context, index) {
                                  final processesUnformatted = jsonDecode(widget
                                      .serviceModel
                                      ?.serviceProcesses as String) as List;
                                  final ServiceProcess processes =
                                      ServiceProcess()
                                          .toModel(processesUnformatted[index]);
                                  return Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.5),
                                      child: Text(
                                          "${index + 1}) ${processes.processName?.capitalize()} for ${processes.processDuration} minutes"));
                                })
                          ],
                        ),
                      )),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _analyticCard(
                                      context,
                                      Icons.group,
                                      colorStyles['darker_purple'],
                                      "32",
                                      "sessions booked"),
                                  _analyticCard(
                                      context,
                                      Icons.sentiment_satisfied,
                                      colorStyles['darker_green'],
                                      "87%",
                                      "customer satisfaction"),
                                ],
                              ),
                              Row(
                                children: [
                                  _analyticCard(
                                      context,
                                      Icons.group,
                                      colorStyles['darker_blue'],
                                      "405 mins",
                                      "average length"),
                                  _analyticCard(
                                      context,
                                      Icons.trending_up,
                                      colorStyles['dark_purple'],
                                      "#3",
                                      "popularity")
                                ],
                              ),
                            ],
                          ))),
                  GridMedia(images: widget.serviceMedia)
                ])
              : TabBarView(controller: tabController, children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ]),
        ),
      )
    ]));
  }
}

Widget _analyticCard(context, icon, color, value, description) {
  return Flexible(
      flex: 1,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Icon(
                    icon,
                    size: 25,
                    color: color,
                  ),
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ])),
      ));
}
