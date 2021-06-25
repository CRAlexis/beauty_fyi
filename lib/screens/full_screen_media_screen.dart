import 'dart:io';

import 'package:beauty_fyi/bloc/full_screen_media_bloc.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:social_share/social_share.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaScreen extends StatefulWidget {
  final List<ServiceMedia> args;
  const FullScreenMediaScreen({Key? key, required this.args}) : super(key: key);
  @override
  _FullScreenMediaScreenState createState() => _FullScreenMediaScreenState();
}

class _FullScreenMediaScreenState extends State<FullScreenMediaScreen> {
  // will need to take in a list
  // page view builder
  // will need to take index, to know which image to start on
  // will need to stop vidoes if you scroll of the page -> might be automatic

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _fullScreenMediaBloc.eventSink
            .add(FullScreenMediaEvent.OverlayState),
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                showMenuIcon: false,
                leftIconClicked: () {
                  Navigator.pop(context);
                },
                automaticallyImplyLeading: false),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  widget.args['file_type'] == "video"
                      ? //video
                      : //photo
                      //overlay will need to go inside individual page
                      // invidividual page will need to cover entire screen
                  
                ],
              ),
            )));
  }
}

class _Overlay extends StatefulWidget {
  final String? type;
  final FullScreenMediaBloc? fullScreenMediaBloc;
  final onShareImage;
  _Overlay({this.type, this.fullScreenMediaBloc, this.onShareImage});
  @override
  _OverlayState createState() => _OverlayState();
}

class _OverlayState extends State<_Overlay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: true,
        stream: widget.fullScreenMediaBloc!.overlayStateStream,
        builder: (context, snapshot) {
          snapshot.data as bool
              ? _customAnimationControl = CustomAnimationControl.play
              : _customAnimationControl =
                  CustomAnimationControl.playReverseFromEnd;
          return CustomAnimation<double>(
              duration: Duration(milliseconds: 200),
              control: _customAnimationControl,
              tween: Tween(begin: 0, end: 1),
              builder: (context, child, value) {
                return Opacity(
                  opacity: value,
                  child: Visibility(
                      maintainState: true,
                      visible: value != 0,
                      child: Stack(
                        children: [
                          widget.type == "video"
                              ? Align(
                                  alignment: Alignment.center,
                                  child: StreamBuilder(
                                    initialData: true,
                                    stream: widget.fullScreenMediaBloc!
                                        .videoPlayPauseStateStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return IconButton(
                                          icon: Icon(
                                            snapshot.data as bool
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                7,
                                          ),
                                          onPressed: () => widget
                                              .fullScreenMediaBloc!.eventSink
                                              .add(FullScreenMediaEvent
                                                  .VideoPlayPauseState),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ))
                              : Container(),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      icon: Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size:
                                            MediaQuery.of(context).size.width /
                                                11,
                                      ),
                                      onPressed: () => widget.onShareImage()),
                                  IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size:
                                            MediaQuery.of(context).size.width /
                                                11,
                                      ),
                                      onPressed: null)
                                ],
                              ))
                        ],
                      )),
                );
              });
        });
  }
}

class _VideoScreen extends StatefulWidget {
  final ServiceMedia serviceMedia;
  const _VideoScreen({Key? key, required this.serviceMedia}) : super(key: key);

  @override
  __VideoScreenState createState() => __VideoScreenState();
}

class __VideoScreenState extends State<_VideoScreen> {
  CustomAnimationControl _customAnimationControl = CustomAnimationControl.play;
  Future<bool>? isVideoPlaying;
  late VideoPlayerController _videoPlayerController;
  Future<void>? _initialiseFuturePlayer;
  final FullScreenMediaBloc _fullScreenMediaBloc = FullScreenMediaBloc();

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(
        File(widget.serviceMedia.filePath as String));
    _initialiseFuturePlayer = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.play();

    _fullScreenMediaBloc.videoPlayPauseStateStream.listen((event) {
      event ? _videoPlayerController.play() : _videoPlayerController.pause();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _fullScreenMediaBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          FutureBuilder(
                          future: _initialiseFuturePlayer,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Align(
                                alignment: Alignment.center,
                                child: VideoPlayer(_videoPlayerController),
                              );
                            } else {
                              return Container();
                            }
                          }),
          _Overlay(
                    type: widget.serviceMedia.fileType,
                    fullScreenMediaBloc: _fullScreenMediaBloc,
                    onShareImage: () {
                      SocialShare.shareOptions("Shared from Beauty-FYI",
                          imagePath: widget.serviceMedia.filePath);
                    },
                  )
        ],
      ),
    );
  }
}
