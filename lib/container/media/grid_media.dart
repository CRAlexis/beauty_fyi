import 'dart:io';

import 'package:beauty_fyi/models/service_media_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GridMedia extends StatefulWidget {
  final List<ServiceMedia> images;
  GridMedia({required this.images});
  @override
  _GridMediaState createState() => _GridMediaState();
}

class _GridMediaState extends State<GridMedia> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: colorStyles['cream'],
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: (widget.images.length / 4).ceil(),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  widget.images[index * 4].fileType == "image"
                      ? _ImageSqaure(
                          allMedia: widget.images,
                          imageFile: File(widget.images[index * 4].filePath!),
                          isEnd: false,
                          index: index * 4,
                        )
                      : _VideoSqaure(
                          allMedia: widget.images,
                          videoFile: File(widget.images[index * 4].filePath!),
                          isEnd: false,
                          index: index * 4,
                        ),
                  widget.images.length > (index * 4) + 1
                      ? widget.images[(index * 4) + 1].fileType == "image"
                          ? _ImageSqaure(
                              allMedia: widget.images,
                              imageFile: File(
                                  widget.images[(index * 4) + 1].filePath!),
                              isEnd: false,
                              index: (index * 4) + 1)
                          : _VideoSqaure(
                              allMedia: widget.images,
                              videoFile: File(
                                  widget.images[(index * 4) + 1].filePath!),
                              isEnd: false,
                              index: (index * 4) + 1)
                      : _PlaceholderSqaure(isEnd: false),
                  widget.images.length > (index * 4) + 2
                      ? widget.images[(index * 4) + 2].fileType == "image"
                          ? _ImageSqaure(
                              allMedia: widget.images,
                              imageFile: File(
                                  widget.images[(index * 4) + 2].filePath!),
                              isEnd: false,
                              index: (index * 4) + 2)
                          : _VideoSqaure(
                              allMedia: widget.images,
                              videoFile: File(
                                  widget.images[(index * 4) + 2].filePath!),
                              isEnd: false,
                              index: (index * 4) + 2)
                      : _PlaceholderSqaure(isEnd: false),
                  widget.images.length > (index * 4) + 3
                      ? widget.images[(index * 4) + 3].fileType == "image"
                          ? _ImageSqaure(
                              allMedia: widget.images,
                              imageFile: File(
                                  widget.images[(index * 4) + 3].filePath!),
                              isEnd: true,
                              index: (index * 4) + 3,
                            )
                          : _VideoSqaure(
                              allMedia: widget.images,
                              videoFile: File(
                                  widget.images[(index * 4) + 3].filePath!),
                              isEnd: true,
                              index: (index * 4) + 3,
                            )
                      : _PlaceholderSqaure(isEnd: true)
                ],
              );
            }));
  }
}

class _ImageSqaure extends StatelessWidget {
  final List<ServiceMedia> allMedia;
  final File? imageFile;
  final bool? isEnd;
  final int? index;

  _ImageSqaure(
      {required this.allMedia, this.imageFile, this.isEnd, this.index});
  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: AspectRatio(
            aspectRatio: 1 / 1,
            child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/full-screen-media",
                        arguments: {
                          'media': allMedia,
                          'initialIndex': index,
                        }),
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
  final List<ServiceMedia>? allMedia;
  final File? videoFile;
  final bool? isEnd;
  final int? index;

  _VideoSqaure({this.allMedia, this.videoFile, this.isEnd, this.index});

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
    _controller.pause();
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
    print("should be here once");
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
                                context, "/full-screen-media",
                                arguments: {
                                  // 'file_type': 'video',
                                  // 'file_path': widget.videoFile
                                  'media': widget.allMedia,
                                  'initialIndex': widget.index,
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
                color: colorStyles['cream'],
              ),
            )));
  }
}
