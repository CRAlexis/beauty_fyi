import 'dart:async';

import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/live_session/bottom_bar.dart';
import 'package:beauty_fyi/container/live_session/camera_preview.dart';
import 'package:beauty_fyi/container/live_session/countdown.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class LiveSessionScreen extends StatefulWidget {
  final args;
  const LiveSessionScreen({Key key, this.args}) : super(key: key);
  @override
  _LiveSessionScreenState createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController tabController;
  int timeInSeconds;
  String processName;
  int processIndex = 0; // Will need to fetch this from database
  CameraDescription camera;
  CameraController cameraController;
  Future<void> initialiseCameraControllerFuture;
  bool displayCamera = true;
  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 3, vsync: this);
    tabController.index = 1;
    fetchServiceData();
    initCameras(index: cameraIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch (state.toString()) {
      case 'AppLifecycleState.paused':
        break;
      case 'AppLifecylcleState.inactive':
        break;
      case 'AppLifecycleState.resumed':
        initCameras(index: cameraIndex);
        if (tabController.index == 0) tabController.index = 1;
        break;
      default:
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void fetchServiceData() async {
    print(widget.args);
    final serviceModel = new ServiceModel(id: widget.args['service_id']);
    final service = await serviceModel.readService();
    List<Map<String, dynamic>> processes =
        (jsonDecode(service['service_processes']) as List)
            .map((e) => e as Map<String, dynamic>)
            ?.toList();

    getCurrentProcess(processes);
  }

  void getCurrentProcess(processes) {
    processName = processes[processIndex].keys.first;
    timeInSeconds = processes[processIndex].values.first * 60;
  }

  Future<void> initCameras({index = 0}) async {
    cameraIndex = index;
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    camera = cameras[index];
    cameraController = CameraController(camera, ResolutionPreset.high);
    initialiseCameraControllerFuture = cameraController.initialize();
    return;
  }

  Widget build(BuildContext context) {
    tabController.addListener(() {
      setState(() {
        if (tabController.index == 0) {
          displayCamera = true;
        } else {
          displayCamera = false;
        }
      });
    });
    return new WillPopScope(
        onWillPop: () async {
          return Future.value(true);
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                rightIcon: null,
                leftIconClicked: () {
                  Navigator.pop(context);
                },
                rightIconClicked: () {},
                automaticallyImplyLeading: false),
            body: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  colorStyles['dark_purple'],
                  colorStyles['light_purple'],
                  colorStyles['blue'],
                  colorStyles['green']
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(alignment: Alignment.topCenter, children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 00),
                    child: TabBarView(controller: tabController, children: [
                      displayCamera
                          ? CameraPreviewScreen(
                              cameraController: cameraController,
                              initialiseCameraControllerFuture:
                                  initialiseCameraControllerFuture,
                            )
                          : SizedBox(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          timeInSeconds != null
                              ? CountDown(
                                  timeInSeconds: 1, //timeInSeconds,
                                  processName: processName,
                                  secondCallBack: (timeInSeconds) {},
                                  processIsFinished: () {})
                              : CountDownRefresh(
                                  refresher: () {
                                    setState(() {});
                                  },
                                )
                        ],
                      ),
                      Text("here"),
                    ]),
                  ),
                  LiveSessionBottomBar(
                      tabController: tabController,
                      switchCamera: () async {
                        cameraIndex == 0
                            ? await initCameras(index: 1)
                            : await initCameras(index: 0);
                        setState(() {});
                      },
                      onTakePhoto: () async {
                        try {
                          print("Taking photo*");
                          final p = await getTemporaryDirectory();
                          final String name =
                              DateTime.now().toString().replaceAll(" ", "");
                          final path = "${p.path}/$name.png";
                          await cameraController.takePicture(path);
                          final serviceMedia = new ServiceMedia(
                              sessionId: 1,
                              serviceId: widget.args['service_id'],
                              fileType: "image",
                              filePath: path);
                          await serviceMedia.insertServiceMedia(serviceMedia);
                          setState(() {});
                        } catch (e) {
                          print(e);
                          //unable to take photo -> might have to do alert dialoug
                        }
                      },
                      onStartRecording: () {},
                      onStopRecording: () {})
                ]))));
  }
}

class CountDownRefresh extends StatelessWidget {
  final refresher;
  CountDownRefresh({this.refresher});
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2)).then((value) {
      refresher();
    });
    return SizedBox();
  }
}
