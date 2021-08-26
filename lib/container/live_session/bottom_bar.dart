import 'dart:async';
import 'dart:io';

import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/models/service_media_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:video_player/video_player.dart';

class LiveSessionBottomBar extends StatefulWidget {
  final takePhoto;
  final startRecording;
  final stopRecording;
  final switchCamera;
  final GalleryBloc galleryBloc;
  final SessionModel sessionModel;
  final TabController tabController;
  LiveSessionBottomBar(this.galleryBloc, this.sessionModel, this.tabController,
      {required this.takePhoto,
      required this.startRecording,
      required this.stopRecording,
      required this.switchCamera});
  @override
  _LiveSessionBottomBarState createState() => _LiveSessionBottomBarState();
}

class _LiveSessionBottomBarState extends State<LiveSessionBottomBar> {
  CustomAnimationControl customAnimationControlTabBar =
      CustomAnimationControl.play;
  CustomAnimationControl customAnimationControlCamera =
      CustomAnimationControl.stop;
  @override
  Widget build(BuildContext context) {
    widget.tabController.addListener(() {
      setState(() {
        if (widget.tabController.index == 0) {
          customAnimationControlTabBar = CustomAnimationControl.playReverse;
          // customAnimationControlCamera = CustomAnimationControl.stop;
        } else {
          customAnimationControlCamera = CustomAnimationControl.playReverse;
          customAnimationControlTabBar = CustomAnimationControl.stop;
        }
      });
    });
    return Align(
        alignment: Alignment.bottomCenter,
        child: Stack(children: [
          CustomAnimation<double>(
              animationStatusListener: (AnimationStatus status) {
                if (status == AnimationStatus.completed) {}
                if (status == AnimationStatus.dismissed) {
                  setState(() {
                    customAnimationControlCamera = CustomAnimationControl.play;
                  });
                }
              },
              control: customAnimationControlTabBar,
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 200),
              builder: (context, child, value) {
                return Opacity(
                    alwaysIncludeSemantics: false,
                    opacity: value,
                    child: Visibility(
                      visible: value == 1,
                      child: Material(
                        color: Colors.transparent,
                        child: TabBar(
                          controller: widget.tabController,
                          labelPadding: EdgeInsets.all(2),
                          tabs: [
                            Tab(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.camera_alt),
                                Text("Camera"),
                              ],
                            )),
                            Tab(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.radio_button_unchecked),
                                Text("Service"),
                              ],
                            )),
                            Tab(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.edit),
                                Text("Notes"),
                              ],
                            )),
                          ],
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorPadding: EdgeInsets.all(3.0),
                          indicatorColor: Colors.white,
                        ),
                      ),
                    ));
              }),
          CustomAnimation<double>(
              animationStatusListener: (AnimationStatus status) {
                if (status == AnimationStatus.dismissed) {
                  setState(() {
                    customAnimationControlTabBar = CustomAnimationControl.play;
                  });
                }
              },
              control: customAnimationControlCamera,
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 200),
              builder: (context, child, value) {
                return Opacity(
                    alwaysIncludeSemantics: false,
                    opacity: value,
                    child: Visibility(
                        visible: value == 0 ? false : true,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            height: 100,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 15, top: 38),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: GalleryIcon(widget.galleryBloc),
                                  ),
                                ),
                                Consumer(builder: (context, watch, child) {
                                  return Align(
                                      alignment: Alignment.center,
                                      child: CircleButton(
                                        onTakePhoto: () => widget.takePhoto(),
                                        onStartRecording: () =>
                                            widget.startRecording(),
                                        onStopRecording: () =>
                                            widget.stopRecording(),
                                      ));
                                }),
                                GestureDetector(
                                  onTap: () => widget.switchCamera(),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, top: 38),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.flip_camera_android,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )));
              })
        ]));
  }
}

class CircleButton extends StatefulWidget {
  final onTakePhoto;
  final onStartRecording;
  final onStopRecording;
  CircleButton({this.onTakePhoto, this.onStartRecording, this.onStopRecording});
  @override
  _CircleButtonState createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool tapDownActive = false;
  bool recording = false;
  bool takePhoto = false;
  bool buffer = false;
  bool animate = false;
  @override
  Widget build(BuildContext context) {
    if (buffer) {
      Timer(Duration(milliseconds: 500), () {
        buffer = false;
      });
    }
    return GestureDetector(
      onTapDown: (TapDownDetails tapDownDetails) {
        if (buffer) return;
        tapDownActive = true;
        Timer(Duration(milliseconds: 500), () {
          if (tapDownActive) {
            widget.onStartRecording();
            recording = true;
            setState(() {
              animate = true;
              buffer = true;
            });
          }
        });
      },
      onTapUp: (TapUpDetails tapUpDetails) {
        tapDownActive = false;
        if (recording) {
          widget.onStopRecording();
          setState(() {
            recording = false;
            animate = false;
            buffer = true;
          });
        } else {
          if (buffer) return;
          setState(() {
            takePhoto = true;
            animate = true;
            buffer = true;
            widget.onTakePhoto();
          });
          Timer(Duration(milliseconds: 100), () {
            setState(() {
              takePhoto = false;
              animate = false;
            });
          });
        }
      },
      onTapCancel: () {
        tapDownActive = false;
        if (recording) {
          widget.onStopRecording();
          setState(() {
            recording = false;
            animate = false;
            buffer = true;
          });
        } else {
          if (buffer) return;
          setState(() {
            takePhoto = true;
            animate = true;
            buffer = true;
            widget.onTakePhoto();
          });
          Timer(Duration(milliseconds: 100), () {
            setState(() {
              takePhoto = false;
              animate = false;
            });
          });
        }
      },
      child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          width: animate
              ? takePhoto
                  ? MediaQuery.of(context).size.width / 4
                  : MediaQuery.of(context).size.width / 4 + 4
              : MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
            color: animate
                ? takePhoto
                    ? Colors.white
                    : Color.fromRGBO(255, 137, 137, 1)
                : Color.fromRGBO(255, 255, 255, 0.2),
            border: Border.all(color: Colors.white, width: 3),
            shape: BoxShape.circle,
          )),
    );
  }
}

class GalleryIcon extends StatelessWidget {
  final GalleryBloc galleryBloc;
  GalleryIcon(this.galleryBloc);

  Widget build(BuildContext context) {
    try {
      galleryBloc.eventSink.add(galleryBloc.sessionModel!.id as String);
    } catch (e) {}
    return StreamBuilder<ServiceMedia>(
        stream: galleryBloc.serviceMediaStream,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
                onTap: () async {
                  try {
                    print("# Tapped");
                    final List<ServiceMedia> images = await ServiceMedia()
                        .readServiceMedia(
                            sql: "session_id = ?",
                            args: [snapshot.data!.sessionId as String]);
                    print("# media: $images");
                    Navigator.pushNamed(context, "/gallery-screen",
                        arguments: {'media': images});
                  } catch (e) {
                    print(e);
                  }
                },
                child: snapshot.data!.fileType == "image"
                    ? Container(
                        height: MediaQuery.of(context).size.width / 6.5,
                        width: MediaQuery.of(context).size.width / 6.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.white, width: 2),
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                                File(snapshot.data!.filePath as String)),
                          ),
                        ))
                    : Container(
                        height: MediaQuery.of(context).size.width / 6.5,
                        width: MediaQuery.of(context).size.width / 6.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.white, width: 2),
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                        ),
                        child: _VideoSqaure(
                          File(snapshot.data!.filePath as String),
                        )));
          } else {
            return Container(
                padding: EdgeInsets.only(bottom: 20),
                height: MediaQuery.of(context).size.width / 6.5,
                width: MediaQuery.of(context).size.width / 6.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                ));
          }
        });
  }
}

class _VideoSqaure extends StatefulWidget {
  final File? videoFile;

  _VideoSqaure(this.videoFile);

  @override
  __VideoSqaureState createState() => __VideoSqaureState();
}

class __VideoSqaureState extends State<_VideoSqaure> {
  late VideoPlayerController _controller;
  Future<void>? _initialiseVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.videoFile!);
    _initialiseVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialiseVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  child: VideoPlayer(_controller),
                ));
          } else {
            return Container();
          }
        });
  }
}
