import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class LiveSessionBottomBar extends StatefulWidget {
  final TabController tabController;
  final onTakePhoto;
  final onStartRecording;
  final onStopRecording;
  final switchCamera;
  LiveSessionBottomBar(
      {this.tabController,
      this.onTakePhoto,
      this.onStartRecording,
      this.onStopRecording,
      this.switchCamera});
  @override
  _LiveSessionBottomBarState createState() => _LiveSessionBottomBarState();
}

class _LiveSessionBottomBarState extends State<LiveSessionBottomBar> {
  CustomAnimationControl customAnimationControlTabBar =
      CustomAnimationControl.PLAY;
  CustomAnimationControl customAnimationControlCamera =
      CustomAnimationControl.STOP;
  bool showCameraUi = false;
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
                      visible: value == 0 ? false : true,
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
                                    child: GalleryIcon(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleButton(
                                      onTakePhoto: () {
                                        widget.onTakePhoto();
                                        print("Are we here");
                                      },
                                      onStartRecording: () {},
                                      onStopRecording: () {}),
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
            recording = true;
            print("Start recording");
            setState(() {
              animate = true;
              buffer = true;
              widget.onStartRecording();
            });
          }
        });
      },
      onTapUp: (TapUpDetails tapUpDetails) {
        tapDownActive = false;
        if (recording) {
          print("stop recording");
          setState(() {
            recording = false;
            animate = false;
            buffer = true;
            widget.onStopRecording();
          });
        } else {
          if (buffer) return;
          print("take photo");
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
          print("stop recording");
          setState(() {
            recording = false;
            animate = false;
            buffer = true;
            widget.onStopRecording();
          });
        } else {
          if (buffer) return;
          print("take photo");
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
  @override
  _GalleryIconState createState() => _GalleryIconState();
}

class _GalleryIconState extends State<GalleryIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.white, width: 2),
        color: Color.fromRGBO(255, 255, 255, 0.2),
      ),
    );
  }
}
