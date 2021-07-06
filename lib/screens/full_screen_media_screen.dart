import 'dart:io';

import 'package:beauty_fyi/bloc/full_screen_media_bloc.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:social_share/social_share.dart';
import 'package:video_player/video_player.dart';

class FullScreenMediaScreen extends StatefulWidget {
  final args;
  const FullScreenMediaScreen({Key? key, required this.args}) : super(key: key);
  @override
  _FullScreenMediaScreenState createState() => _FullScreenMediaScreenState();
}

class _FullScreenMediaScreenState extends State<FullScreenMediaScreen> {
  final GlobalKey _pageViewKey = GlobalKey();
  late PageController _pageController;
  late List<ServiceMedia> serviceMedia;
  final FullScreenMediaBloc _fullScreenMediaBloc = FullScreenMediaBloc();

  @override
  void initState() {
    super.initState();
    serviceMedia = widget.args['media'];
    _pageController = PageController(initialPage: widget.args['initialIndex']);
  }

  //delete in database
  //remove index from servicemedia list
  //set state

  @override
  void dispose() {
    _fullScreenMediaBloc.dispose();
    super.dispose();
  }
  // will need to take in a list
  // page view builder
  // will need to take index, to know which image to start on
  // will need to stop vidoes if you scroll of the page -> might be automatic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                PageView.builder(
                    key: _pageViewKey,
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: (value) {},
                    itemCount: serviceMedia.length,
                    itemBuilder: (BuildContext context, index) {
                      return serviceMedia[index].fileType == 'video'
                          ? _VideoScreen(
                              serviceMedia: serviceMedia[index],
                              fullScreenMediaBloc: _fullScreenMediaBloc,
                              index: index)
                          : _ImageScreen(
                              serviceMedia: serviceMedia[index],
                              fullScreenMediaBloc: _fullScreenMediaBloc);
                    }),
                _Overlay(
                  pageController: _pageController,
                  serviceMedia: serviceMedia,
                  fullScreenMediaBloc: _fullScreenMediaBloc,
                )
              ],
            )));
  }
}

class _Overlay extends StatefulWidget {
  final PageController pageController;
  final List<ServiceMedia> serviceMedia;
  final FullScreenMediaBloc fullScreenMediaBloc;
  _Overlay(
      {required this.pageController,
      required this.serviceMedia,
      required this.fullScreenMediaBloc});
  @override
  _OverlayState createState() => _OverlayState();
}

class _OverlayState extends State<_Overlay> {
  CustomAnimationControl _customAnimationControl = CustomAnimationControl.play;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: true,
        stream: widget.fullScreenMediaBloc.overlayStateStream,
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
                                                14,
                                      ),
                                      onPressed: () {
                                        if ((widget.pageController.page! % 1) ==
                                            0) {
                                          SocialShare.shareOptions(
                                              "Shared from Beauty-FYI",
                                              imagePath: widget
                                                  .serviceMedia[widget
                                                      .pageController.page!
                                                      .toInt()]
                                                  .filePath);
                                        }
                                      }),
                                  // IconButton(
                                      // icon: Icon(
                                        // Icons.delete_outline,
                                        // color: Colors.white,
                                        // size:
                                            // MediaQuery.of(context).size.width /
                                                // 14,
                                      // ),
                                      // onPressed: null)
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
  final FullScreenMediaBloc fullScreenMediaBloc;
  final int index;
  const _VideoScreen(
      {Key? key,
      required this.serviceMedia,
      required this.fullScreenMediaBloc,
      required this.index})
      : super(key: key);

  @override
  __VideoScreenState createState() => __VideoScreenState();
}

class __VideoScreenState extends State<_VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  Future<void>? _initialiseFuturePlayer;
  bool isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    try {
      _videoPlayerController = VideoPlayerController.file(
          File(widget.serviceMedia.filePath as String));
      _initialiseFuturePlayer = _videoPlayerController.initialize();
      _videoPlayerController.setLooping(true);
    } catch (e) {}
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.fullScreenMediaBloc.eventSink
              .add(FullScreenMediaEvent.OverlayState);
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              FutureBuilder(
                  future: _initialiseFuturePlayer,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Align(
                        alignment: Alignment.center,
                        child: VideoPlayer(_videoPlayerController),
                      );
                    } else {
                      return Container();
                    }
                  }),
              Align(
                  alignment: Alignment.center,
                  child: StreamBuilder(
                    initialData: isVideoPlaying,
                    stream:
                        widget.fullScreenMediaBloc.videoPlayPauseStateStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        snapshot.data as bool
                            ? _videoPlayerController.play()
                            : _videoPlayerController.pause();
                        return IconButton(
                            icon: Icon(
                              snapshot.data as bool
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width / 7,
                            ),
                            onPressed: () {
                              widget.fullScreenMediaBloc.eventSink.add(
                                  isVideoPlaying
                                      ? FullScreenMediaEvent.VideoPauseState
                                      : FullScreenMediaEvent.VideoPlayState);
                              isVideoPlaying = !isVideoPlaying;
                            });
                      } else {
                        return Container();
                      }
                    },
                  )),
            ],
          ),
        ));
  }
}

class _ImageScreen extends StatefulWidget {
  final ServiceMedia serviceMedia;
  final FullScreenMediaBloc fullScreenMediaBloc;

  const _ImageScreen(
      {Key? key, required this.serviceMedia, required this.fullScreenMediaBloc})
      : super(key: key);

  @override
  __ImageScreenState createState() => __ImageScreenState();
}

class __ImageScreenState extends State<_ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.fullScreenMediaBloc.eventSink
              .add(FullScreenMediaEvent.OverlayState);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Align(
              alignment: Alignment.center,
              child: Image.file(File(widget.serviceMedia.filePath as String))),
        ));
  }
}
