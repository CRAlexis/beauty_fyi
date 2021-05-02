import 'dart:async';
import 'dart:io';
import 'dart:ui';

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
      appBar: CustomAppBar(
          focused: true,
          transparent: false,
          titleText: widget.args['clientName'],
          centerTitle: false,
          leftIcon: Icons.arrow_back,
          rightIcon: null,
          leftIconClicked: () {
            Navigator.pop(context);
          },
          automaticallyImplyLeading: false),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.shade100),
            ),
            SizedBox(
              height: 10,
            ),
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
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<ServiceMedia>>(
                future: images,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.length != 0) {
                    print(snapshot.data);
                    return Container(
                        color: Colors.white,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (snapshot.data.length / 4).ceil(),
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  snapshot.data[index * 4].fileType == "image"
                                      ? _ImageSqaure(
                                          imageFile: File(snapshot
                                              .data[index * 4].filePath),
                                          isEnd: false,
                                        )
                                      : _VideoSqaure(
                                          videoFile: File(snapshot
                                              .data[index * 4].filePath),
                                          isEnd: false,
                                        ),
                                  snapshot.data.length > (index * 4) + 1
                                      ? snapshot.data[(index * 4) + 1]
                                                  .fileType ==
                                              "image"
                                          ? _ImageSqaure(
                                              imageFile: File(snapshot
                                                  .data[(index * 4) + 1]
                                                  .filePath),
                                              isEnd: false,
                                            )
                                          : _VideoSqaure(
                                              videoFile: File(snapshot
                                                  .data[(index * 4) + 1]
                                                  .filePath),
                                              isEnd: false,
                                            )
                                      : _PlaceholderSqaure(isEnd: false),
                                  snapshot.data.length > (index * 4) + 2
                                      ? snapshot.data[index].fileType == "image"
                                          ? _ImageSqaure(
                                              imageFile: File(snapshot
                                                  .data[(index * 4) + 2]
                                                  .filePath),
                                              isEnd: false,
                                            )
                                          : _VideoSqaure(
                                              videoFile: File(snapshot
                                                  .data[(index * 4) + 2]
                                                  .filePath),
                                              isEnd: false,
                                            )
                                      : _PlaceholderSqaure(isEnd: false),
                                  snapshot.data.length > (index * 4) + 3
                                      ? snapshot.data[index].fileType == "image"
                                          ? _ImageSqaure(
                                              imageFile: File(snapshot
                                                  .data[(index * 4) + 3]
                                                  .filePath),
                                              isEnd: true,
                                            )
                                          : _VideoSqaure(
                                              videoFile: File(snapshot
                                                  .data[(index * 4) + 3]
                                                  .filePath),
                                              isEnd: true,
                                            )
                                      : _PlaceholderSqaure(isEnd: true)
                                ],
                              );
                            }));
                  } else {
                    refreshStateTimer = Timer(Duration(seconds: 3), () {
                      setState(() {});
                    });
                    refreshStateTimer.cancel();
                    return CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorStyles['green']),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

Future<List<ServiceMedia>> fetchImages({int clientId}) async {
  return await ServiceMedia()
      .readServiceMedia(sql: "user_id = ?", args: [null]);
}

class _ImageSqaure extends StatelessWidget {
  final File imageFile;
  final bool isEnd;
  _ImageSqaure({this.imageFile, this.isEnd});
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/full-screen-media",
                    arguments: {'file_type': 'image', 'file_path': imageFile}),
                child: Container(
                  padding: isEnd
                      ? EdgeInsets.only(bottom: 2)
                      : EdgeInsets.only(right: 2, bottom: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(imageFile)),
                    ),
                  ),
                ))));
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
            return Flexible(
                flex: 1,
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                                context, "/full-screen-media", arguments: {
                              'file_type': 'video',
                              'file_path': widget.videoFile
                            }),
                        child: Stack(
                          children: [
                            Container(
                                padding: widget.isEnd
                                    ? EdgeInsets.only(bottom: 2)
                                    : EdgeInsets.only(right: 2, bottom: 2),
                                child: Container(
                                  child: VideoPlayer(_controller),
                                )),
                            Align(
                                alignment: Alignment.center,
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width /
                                        10)),
                          ],
                        ))));
          } else {
            return Flexible(
                flex: 1,
                child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      padding: widget.isEnd
                          ? EdgeInsets.only(bottom: 2)
                          : EdgeInsets.only(right: 2, bottom: 2),
                    )));
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
