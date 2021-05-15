import 'dart:async';
import 'dart:io';

import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class LiveSessionBottomBar extends StatefulWidget {
  final TabController tabController;
  final onTakePhoto;
  final onStartRecording;
  final onStopRecording;
  final switchCamera;
  final GalleryBloc galleryBloc;
  final SessionModel sessionModel;
  LiveSessionBottomBar(
      {this.tabController,
      this.onTakePhoto,
      this.onStartRecording,
      this.onStopRecording,
      this.switchCamera,
      this.galleryBloc,
      this.sessionModel});
  @override
  _LiveSessionBottomBarState createState() => _LiveSessionBottomBarState();
}

class _LiveSessionBottomBarState extends State<LiveSessionBottomBar> {
  CustomAnimationControl customAnimationControlTabBar =
      CustomAnimationControl.PLAY;
  CustomAnimationControl customAnimationControlCamera =
      CustomAnimationControl.STOP;
  @override
  Widget build(BuildContext context) {
    widget.tabController.addListener(() {
      setState(() {
        if (widget.tabController.index == 0) {
          customAnimationControlTabBar = CustomAnimationControl.PLAY_REVERSE;
          customAnimationControlCamera = CustomAnimationControl.STOP;
        } else {
          customAnimationControlCamera = CustomAnimationControl.PLAY_REVERSE;
          customAnimationControlTabBar = CustomAnimationControl.STOP;
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
                    customAnimationControlCamera = CustomAnimationControl.PLAY;
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
                    customAnimationControlTabBar = CustomAnimationControl.PLAY;
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
                                    child: GalleryIcon(
                                        galleryBloc: widget.galleryBloc,
                                        sessionModel: widget.sessionModel),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleButton(onTakePhoto: () {
                                    widget.onTakePhoto();
                                  }, onStartRecording: () {
                                    widget.onStartRecording();
                                  }, onStopRecording: () {
                                    widget.onStopRecording();
                                  }),
                                ),
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
            print("Start recording");
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
                  ? MediaQuery.of(context).size.width / 5
                  : MediaQuery.of(context).size.width / 5 + 4
              : MediaQuery.of(context).size.width / 5,
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

class GalleryIcon extends StatefulWidget {
  final GalleryBloc galleryBloc;
  final SessionModel sessionModel;

  const GalleryIcon({Key key, this.galleryBloc, this.sessionModel})
      : super(key: key);
  @override
  _GalleryIconState createState() => _GalleryIconState();
}

class _GalleryIconState extends State<GalleryIcon> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    Timer(Duration(seconds: 1), () {
      widget.galleryBloc.eventSink.add({
        GalleryEvent.PhotoCaptured: widget.sessionModel.id
      }); // This does not run on very first instance
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<File>(
        stream: widget.galleryBloc.galleryStream,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
                onTap: () => {
                      Navigator.pushNamed(context, "/gallery-screen",
                          arguments: {"sessionModel": widget.sessionModel})
                    },
                child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.white, width: 2),
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(snapshot.data),
                      ),
                    )));
          } else {
            return GestureDetector(
                onTap: () => {
                      Navigator.pushNamed(context, "/gallery-screen",
                          arguments: {"sessionModel": widget.sessionModel})
                    },
                child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.white, width: 2),
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                    )));
          }
        });
  }
}
