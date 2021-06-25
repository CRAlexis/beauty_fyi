import 'dart:async';

import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/live_session/bottom_bar.dart';
import 'package:beauty_fyi/container/live_session/countdown.dart';
import 'package:beauty_fyi/container/live_session/notes_section.dart';
import 'package:beauty_fyi/container/pageViewWrapper/page_view_wrapper.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/providers/camera_provider.dart';
import 'package:beauty_fyi/providers/liveSession/live_session_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final liveSessionNotifierProvider = StateNotifierProvider.family(
    (ref, SessionModel? params) => LiveSessionNotifier(params));
final cameraNotifierProvider = StateNotifierProvider.autoDispose.family((ref,
        GalleryBloc params) =>
    CameraNotifier(params)); //need to pass session ID to here -> not sure how

class LiveSessionScreen extends StatefulWidget {
  final args;
  const LiveSessionScreen({Key? key, this.args}) : super(key: key);
  @override
  _LiveSessionScreenState createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController tabController;
  int processIndex = 0; // Will need to fetch this from database
  late GalleryBloc galleryBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    tabController = TabController(length: 3, vsync: this);
    tabController.index = 1;
    galleryBloc = GalleryBloc(widget.args['sessionModel']);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state.toString()) {
      case 'AppLifecycleState.paused':
        //need to check if countdown provider runs when paused, if not will need to work out diffe
        break;
      case 'AppLifecylcleState.inactive':
        break;
      case 'AppLifecycleState.resumed':
        context.read(liveSessionNotifierProvider(null).notifier).appResumed();
        if (tabController.index == 0) tabController.index = 1;
        break;
      default:
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    galleryBloc.dipose();
    super.dispose();
  }

  /*
    tabController!.addListener(() {
      setState(() {
        if (tabController!.index == 0) {
          displayCamera = true;
        } else {
          displayCamera = false;
        }
      });
  */

  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final state =
          watch(liveSessionNotifierProvider(widget.args['sessionModel']));
      final liveSessionNotifierController = context.read(
          liveSessionNotifierProvider(widget.args['sessionModel']).notifier);
      // final cameraController = context.read(cameraNotifierProvider.notifier);
      print("#live session screen initialised");
      print("live session screen state: $state");

      return new WillPopScope(
          onWillPop: () async {
            if (tabController.index == 0) {
              tabController.animateTo(1,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOutCirc);
              return Future.value(false);
            } else {
              // await disposeCameras();
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
                  showMenuIcon: false,
                  leftIconClicked: () async {
                    if (tabController.index == 0) {
                      tabController.animateTo(1,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCirc);
                    } else {
                      // await disposeCameras();
                      Navigator.pop(context);
                    }
                  },
                  automaticallyImplyLeading: false),
              body: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors:
                              liveSessionNotifierController.backgroundColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  child: state is LiveSessionLoading
                      ? Center(child: CircularProgressIndicator())
                      : state is LiveSessionActive
                          ? Stack(alignment: Alignment.topCenter, children: <
                              Widget>[
                              Container(
                                child: TabBarView(
                                    controller: tabController,
                                    children: [
                                      CameraPreviewScreen(
                                          liveSessionNotifierController
                                              .sessionModel as SessionModel,
                                          galleryBloc),
                                      // /need to check if slide is 1 to display?
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          PageViewWrapper(
                                              child: CountDown(
                                                  state
                                                      .processDurationInSeconds,
                                                  state.serviceProcess,
                                                  state.sessionFinished,
                                                  onPaused: () =>
                                                      liveSessionNotifierController
                                                          .countdownPaused(),
                                                  onResumed: () =>
                                                      liveSessionNotifierController
                                                          .countdownResumed(),
                                                  onStartNextProcess: () =>
                                                      liveSessionNotifierController
                                                          .startNextProcess()),
                                              keepAlive: true)
                                        ],
                                      ),
                                      NotesSection(
                                          sessionModel:
                                              widget.args['sessionModel']),
                                    ]),
                              ),
                              LiveSessionBottomBar(
                                galleryBloc,
                                liveSessionNotifierController.sessionModel
                                    as SessionModel,
                                tabController,
                                takePhoto: () => context
                                    .read(cameraNotifierProvider(galleryBloc)
                                        .notifier)
                                    .takePhoto(widget.args['sessionModel']),
                                startRecording: () => context
                                    .read(cameraNotifierProvider(galleryBloc)
                                        .notifier)
                                    .startRecording(),
                                stopRecording: () => context
                                    .read(cameraNotifierProvider(galleryBloc)
                                        .notifier)
                                    .stopRecording(widget.args['sessionModel']),
                                switchCamera: () => context
                                    .read(cameraNotifierProvider(galleryBloc)
                                        .notifier)
                                    .initCamera(
                                        index: context
                                                    .read(
                                                        cameraNotifierProvider(
                                                                galleryBloc)
                                                            .notifier)
                                                    .cameraIndex ==
                                                0
                                            ? 1
                                            : 0),
                              )
                            ])
                          : state is LiveSessionError
                              ? Center(
                                  child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontFamily: 'OpenSans'),
                                ))
                              : Center(child: CircularProgressIndicator()))));
    });
  }
}

class CameraPreviewScreen extends ConsumerWidget {
  final SessionModel _sessionModel;
  final GalleryBloc galleryBloc;
  CameraPreviewScreen(this._sessionModel, this.galleryBloc);

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // this will work with consumer widget
    switch (state.toString()) {
      case 'AppLifecycleState.paused':
        break;
      case 'AppLifecylcleState.inactive':
        break;
      case 'AppLifecycleState.resumed':
        //init camera
        break;
      default:
    }
  }

  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(cameraNotifierProvider(galleryBloc));
    final mediaSize = MediaQuery.of(context).size;
    final scale = print("# $state");
    return ProviderListener(
        onChange: (BuildContext context, state) {
          if (state is CameraCaptureError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              duration: Duration(seconds: 6),
            ));
          }
        },
        provider: cameraNotifierProvider(galleryBloc),
        child: Stack(
          children: [
            state is CameraLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : state is CameraLoaded
                    ? ClipRect(
                        clipper: _MediaSizeClipper(mediaSize),
                        child: Transform.scale(
                          scale: 1 /
                              (state.cameraController.value.aspectRatio *
                                  mediaSize.aspectRatio),
                          alignment: Alignment.topCenter,
                          child: CameraPreview(state.cameraController),
                        ),
                      )
                    // ? Container(
                    // child: Text("camrea laoded"),
                    // )
                    : state is CameraLoadingError
                        ? Center(
                            child: Text(state.message),
                          )
                        : Container(),
          ],
        ));
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
