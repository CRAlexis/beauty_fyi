import 'dart:async';

import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/live_session/bottom_bar.dart';
import 'package:beauty_fyi/container/live_session/camera_preview.dart';
import 'package:beauty_fyi/container/live_session/countdown.dart';
import 'package:beauty_fyi/container/live_session/notes_section.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
  CameraDescription camera;
  CameraController cameraController;
  Future<void> initialiseCameraControllerFuture;
  Timer processFinishedTimer;
  Timer sessionFinishedTimer;
  bool displayCamera = true;
  int cameraIndex = 0;
  String videoFileName;
  final GalleryBloc _galleryBloc = GalleryBloc();
  List<Color> backgroundColors = [
    colorStyles['dark_purple'],
    colorStyles['light_purple'],
    colorStyles['blue'],
    colorStyles['green']
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 3, vsync: this);
    tabController.index = 1;
    initCameras(index: cameraIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    tabController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _galleryBloc.dipose();
    try {
      processFinishedTimer.cancel();
      sessionFinishedTimer.cancel();
    } catch (e) {}
    super.dispose();
  }

  Future<void> disposeCameras() async {
    try {
      cameraIndex = null;
      await cameraController.dispose();
      return;
    } catch (e) {
      print(e);
    }
  }

  Future<void> initCameras({index = 0}) async {
    cameraIndex = index;
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    camera = cameras[index];
    cameraController = CameraController(camera, ResolutionPreset.max);
    initialiseCameraControllerFuture = cameraController.initialize();
    return;
  }

  void sessionFinished() {
    backgroundColors = [
      colorStyles['darker_green'],
      colorStyles['green'],
      colorStyles['blue'],
      colorStyles['green']
    ];
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
          if (tabController.index == 0) {
            tabController.animateTo(1,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCirc);
            return Future.value(false);
          } else {
            await disposeCameras();
            return Future.value(true);
          }
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                rightIcon: null,
                leftIconClicked: () async {
                  if (tabController.index == 0) {
                    tabController.animateTo(1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOutCirc);
                  } else {
                    await disposeCameras();
                    print("this should be second");
                    Navigator.pop(context);
                  }
                },
                rightIconClicked: () {},
                automaticallyImplyLeading: false),
            body: AnimatedContainer(
                duration: Duration(milliseconds: 1000),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: backgroundColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Stack(alignment: Alignment.topCenter, children: <Widget>[
                  Container(
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
                          CountDown(
                            secondCallBack: (timeInSeconds) {},
                            sessionFinished: () {
                              sessionFinishedTimer =
                                  Timer(Duration(milliseconds: 1250), () {
                                setState(() {
                                  sessionFinished();
                                });
                              });
                            },
                            startingNextProcess: () {
                              setState(() {
                                backgroundColors = [
                                  colorStyles['blue'],
                                  colorStyles['cream'],
                                  colorStyles['green'],
                                  colorStyles['cream']
                                ];
                              });
                              processFinishedTimer =
                                  Timer(Duration(milliseconds: 1000), () {
                                setState(() {
                                  backgroundColors = [
                                    colorStyles['dark_purple'],
                                    colorStyles['light_purple'],
                                    colorStyles['blue'],
                                    colorStyles['green']
                                  ];
                                });
                              });
                            },
                            sessionModel: widget.args['sessionModel'],
                          )
                        ],
                      ),
                      NotesSection(sessionModel: widget.args['sessionModel']),
                    ]),
                  ),
                  LiveSessionBottomBar(
                      sessionModel: widget.args['sessionModel'],
                      tabController: tabController,
                      galleryBloc: _galleryBloc,
                      switchCamera: () async {
                        cameraIndex == 0
                            ? await initCameras(index: 1)
                            : await initCameras(index: 0);
                        setState(() {});
                      },
                      onTakePhoto: () async {
                        try {
                          takePhoto(
                              cameraController: cameraController,
                              galleryBloc: _galleryBloc,
                              sessionModel: widget.args['sessionModel']);
                        } catch (e) {
                          print(e);
                          //unable to take photo -> might have to do alert dialoug
                        }
                      },
                      onStartRecording: () {
                        videoFileName =
                            DateTime.now().toString().replaceAll(" ", "");
                        startRecording(
                            cameraController: cameraController,
                            sessionModel: widget.args['sessionModel'],
                            galleryBloc: _galleryBloc,
                            videoFileName: videoFileName);
                      },
                      onStopRecording: () {
                        stopRecording(
                            cameraController: cameraController,
                            sessionModel: widget.args['sessionModel'],
                            galleryBloc: _galleryBloc,
                            videoFileName: videoFileName);
                        videoFileName = null;
                      })
                ]))));
  }
}

void takePhoto(
    {cameraController,
    SessionModel sessionModel,
    GalleryBloc galleryBloc,
    clientId}) async {
  try {
    final p = await getTemporaryDirectory();
    final String name = DateTime.now().toString().replaceAll(" ", "");
    final path = "${p.path}/$name.png";
    await cameraController.takePicture(path);
    final serviceMedia = ServiceMedia(
        sessionId: sessionModel.id,
        serviceId: sessionModel.serviceId,
        fileType: "image",
        filePath: path,
        userId: sessionModel.clientId);
    await serviceMedia.insertServiceMedia(serviceMedia);
    galleryBloc.eventSink.add({GalleryEvent.PhotoCaptured: 1});
  } catch (error) {
    return Future.error(error, StackTrace.fromString(""));
  }
}

void startRecording(
    {cameraController,
    SessionModel sessionModel,
    galleryBloc,
    videoFileName}) async {
  final p = await getTemporaryDirectory();
  final path = "${p.path}/$videoFileName.mp4";
  print("#tag Started reocording");
  await cameraController.startVideoRecording(path);
}

void stopRecording(
    {cameraController,
    SessionModel sessionModel,
    galleryBloc,
    videoFileName}) async {
  try {
    print("#tag Finished reocording");
    final p = await getTemporaryDirectory();
    final path = "${p.path}/$videoFileName.mp4";
    await cameraController.stopVideoRecording();
    final serviceMedia = ServiceMedia(
        sessionId: sessionModel.id,
        serviceId: sessionModel.serviceId,
        fileType: "video",
        filePath: path);
    await serviceMedia.insertServiceMedia(serviceMedia);
    // galleryBloc.eventSink.add({GalleryEvent.VideoCaptured: 1});
  } catch (error) {
    return Future.error(error, StackTrace.fromString(""));
  }
}
