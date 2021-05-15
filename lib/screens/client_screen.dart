import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ClientScreen extends StatefulWidget {
  final args;
  ClientScreen({this.args});
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  Future<List<ServiceMedia>> images;
  Timer refreshStateTimer;
  @override
  void initState() {
    super.initState();
    print("client id: ${widget.args['clientId']}");
    images = fetchImages(clientId: widget.args['clientId']);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      refreshStateTimer.cancel();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
            focused: true,
            transparent: true,
            dark: false,
            titleText: "", //widget.args['clientName'],
            centerTitle: true,
            leftIcon: Icons.arrow_back,
            rightIcon: null,
            leftIconClicked: () {
              Navigator.pop(context);
            },
            automaticallyImplyLeading: false),
        body: Container(
          // height: double.infinity,
          // width: double.infinity,
          child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _clientHeroImage(
                      context: context,
                      clientImage: widget.args['clientImage']),
                  SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<ServiceMedia>>(
                      future: images,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data.length != 0) {
                          print(snapshot.data);
                          return Container(
                              width: double.infinity,
                              height: 80,
                              color: Colors.white,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return snapshot.data[index].fileType ==
                                            "image"
                                        ? _ImageSqaure(
                                            imageFile: File(
                                                snapshot.data[index].filePath),
                                            isEnd: false,
                                          )
                                        : _VideoSqaure(
                                            videoFile: File(
                                                snapshot.data[index].filePath),
                                            isEnd: false,
                                          );
                                  }));
                        } else {
                          refreshStateTimer = Timer(Duration(seconds: 3), () {
                            setState(() {});
                          });
                          refreshStateTimer.cancel();
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorStyles['green']),
                          );
                        }
                      }),
                  SizedBox(
                    height: 1000,
                  )
                ],
              )),
        ));
  }
}

Future<List<ServiceMedia>> fetchImages({int clientId}) async {
  return await ServiceMedia()
      .readServiceMedia(sql: "user_id = ?", args: [clientId]);
}

Widget _clientHeroImage({BuildContext context, File clientImage}) {
  final GlobalKey _backgroundImageKey = GlobalKey();
  return Flow(
    delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey),
    children: [
      Container(
        height: MediaQuery.of(context).size.height / 2,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  clientImage,
                ))),
      ),
    ],
  );
}

class ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;
  ParallaxFlowDelegate({
    @required this.scrollable,
    @required this.listItemContext,
    @required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);
    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);
    // Calculate the vertical alignment of the background
    // based on the scroll percentage.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);
    // Paint the background.
    context.paintChild(
      0,
      transform: Transform.translate(
        offset: Offset(0.0, childRect.top),
      ).transform,
    );
  }

  @override
  bool shouldRepaint(covariant ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class _ImageSqaure extends StatelessWidget {
  final File imageFile;
  final bool isEnd;
  _ImageSqaure({this.imageFile, this.isEnd});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 82,
        padding: EdgeInsets.only(right: 5),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/full-screen-media",
              arguments: {'file_type': 'image', 'file_path': imageFile}),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: FileImage(imageFile)),
            ),
          ),
        ));
  }
}

class _VideoSqaure extends StatefulWidget {
  final File videoFile;
  final bool isEnd;

  _VideoSqaure({this.videoFile, this.isEnd});

  @override
  __VideoSqaureState createState() => __VideoSqaureState();
}

class __VideoSqaureState extends State<_VideoSqaure> {
  VideoPlayerController _controller;
  Future<void> _initialiseVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.videoFile);
    _initialiseVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialiseVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/full-screen-media",
                        arguments: {
                          'file_type': 'video',
                          'file_path': widget.videoFile
                        }),
                child: Stack(
                  children: [
                    Container(
                        width: 82,
                        padding: EdgeInsets.only(right: 5),
                        child: Container(
                          child: VideoPlayer(_controller),
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.play_arrow,
                            color: Colors.white, size: 10)),
                  ],
                ));
          } else {
            return Container(
              width: 82,
              padding: EdgeInsets.only(right: 2),
            );
          }
        });
  }
}

class _PlaceholderSqaure extends StatelessWidget {
  final bool isEnd;
  _PlaceholderSqaure({this.isEnd});
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              padding: isEnd
                  ? EdgeInsets.only(bottom: 2)
                  : EdgeInsets.only(right: 2, bottom: 2),
              child: Container(
                color: Colors.white,
              ),
            )));
  }
}

/*
return Row(
                                          children: [
                                            snapshot.data.length >
                                                    (index * 4) + 1
                                                ? snapshot.data[(index * 4) + 1]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 1]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 1]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: false),
                                            snapshot.data.length >
                                                    (index * 4) + 2
                                                ? snapshot.data[index]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 2]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 2]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: false),
                                            snapshot.data.length >
                                                    (index * 4) + 3
                                                ? snapshot.data[index]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 3]
                                                            .filePath),
                                                        isEnd: true,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 3]
                                                            .filePath),
                                                        isEnd: true,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: true)
                                          ],
                                        );
                                      
          

Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red.shade200),
                      minimumSize: MaterialStateProperty.all(Size(150, 35))),
                  onPressed: () => null,
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all(colorStyles['green']),
                      minimumSize: MaterialStateProperty.all(Size(150, 35))),
                  onPressed: () => null,
                  child: Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),*/
