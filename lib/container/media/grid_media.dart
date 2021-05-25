import 'dart:io';

import 'package:beauty_fyi/models/service_media.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GridMedia extends StatefulWidget {
  final Future<List<ServiceMedia>>? images;
  GridMedia({required this.images});
  @override
  _GridMediaState createState() => _GridMediaState();
}

class _GridMediaState extends State<GridMedia> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceMedia>>(
        future: widget.images,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            snapshot.data!.toList().forEach((element) {
              // print(element.toMap());
            });
            return Container(
                height: double.infinity,
                width: double.infinity,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (snapshot.data!.length / 4).ceil(),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          snapshot.data![index * 4].fileType == "image"
                              ? _ImageSqaure(
                                  imageFile:
                                      File(snapshot.data![index * 4].filePath!),
                                  isEnd: false,
                                )
                              : _VideoSqaure(
                                  videoFile:
                                      File(snapshot.data![index * 4].filePath!),
                                  isEnd: false,
                                ),
                          snapshot.data!.length > (index * 4) + 1
                              ? snapshot.data![(index * 4) + 1].fileType ==
                                      "image"
                                  ? _ImageSqaure(
                                      imageFile: File(snapshot
                                          .data![(index * 4) + 1].filePath!),
                                      isEnd: false,
                                    )
                                  : _VideoSqaure(
                                      videoFile: File(snapshot
                                          .data![(index * 4) + 1].filePath!),
                                      isEnd: false,
                                    )
                              : _PlaceholderSqaure(isEnd: false),
                          snapshot.data!.length > (index * 4) + 2
                              ? snapshot.data![index].fileType == "image"
                                  ? _ImageSqaure(
                                      imageFile: File(snapshot
                                          .data![(index * 4) + 2].filePath!),
                                      isEnd: false,
                                    )
                                  : _VideoSqaure(
                                      videoFile: File(snapshot
                                          .data![(index * 4) + 2].filePath!),
                                      isEnd: false,
                                    )
                              : _PlaceholderSqaure(isEnd: false),
                          snapshot.data!.length > (index * 4) + 3
                              ? snapshot.data![index].fileType == "image"
                                  ? _ImageSqaure(
                                      imageFile: File(snapshot
                                          .data![(index * 4) + 3].filePath!),
                                      isEnd: true,
                                    )
                                  : _VideoSqaure(
                                      videoFile: File(snapshot
                                          .data![(index * 4) + 3].filePath!),
                                      isEnd: true,
                                    )
                              : _PlaceholderSqaure(isEnd: true)
                        ],
                      );
                    }));
          } else {
            return Container();
          }
        });
  }
}

class _ImageSqaure extends StatelessWidget {
  final File? imageFile;
  final bool? isEnd;
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
                  padding: isEnd!
                      ? EdgeInsets.only(bottom: 2)
                      : EdgeInsets.only(right: 2, bottom: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(imageFile!)),
                    ),
                  ),
                ))));
  }
}

class _VideoSqaure extends StatefulWidget {
  final File? videoFile;
  final bool? isEnd;

  _VideoSqaure({this.videoFile, this.isEnd});

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
                                padding: widget.isEnd!
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
                      padding: widget.isEnd!
                          ? EdgeInsets.only(bottom: 2)
                          : EdgeInsets.only(right: 2, bottom: 2),
                    )));
          }
        });
  }
}

class _PlaceholderSqaure extends StatelessWidget {
  final bool? isEnd;
  _PlaceholderSqaure({this.isEnd});
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              padding: isEnd!
                  ? EdgeInsets.only(bottom: 2)
                  : EdgeInsets.only(right: 2, bottom: 2),
              child: Container(
                color: Colors.grey.shade100,
              ),
            )));
  }
}
