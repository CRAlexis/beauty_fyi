import 'dart:io';

import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

enum GalleryIconSize {
  Small,
  Medium,
  Big,
}

class GalleryIconStack extends StatefulWidget {
  final File? imageSrc;
  final onPreviewImage;
  final onOpenGalleryOrCamera;
  final GalleryIconSize? size;
  const GalleryIconStack(
      {Key? key,
      this.imageSrc,
      this.onPreviewImage,
      this.onOpenGalleryOrCamera,
      this.size})
      : super(key: key);
  @override
  _GalleryIconStackState createState() => _GalleryIconStackState();
}

class _GalleryIconStackState extends State<GalleryIconStack> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          widget.imageSrc == null
              ? MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () => widget.onPreviewImage(),
                  color: Colors.grey.shade200,
                  textColor: Colors.white,
                  child: Icon(
                    Icons.image,
                    size: widget.size == GalleryIconSize.Big
                        ? 80
                        : widget.size == GalleryIconSize.Medium
                            ? 50
                            : widget.size == GalleryIconSize.Small
                                ? 30
                                : 80,
                  ),
                  padding: EdgeInsets.all(36),
                  shape: CircleBorder(),
                  elevation: 0,
                )
              : GestureDetector(
                  onTap: () => widget.onPreviewImage(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: widget.size == GalleryIconSize.Big
                            ? 20
                            : widget.size == GalleryIconSize.Medium
                                ? 5
                                : widget.size == GalleryIconSize.Small
                                    ? 5
                                    : 20,
                        horizontal: 50),
                    child: Hero(
                        tag: "full_screen_image_hero",
                        child: CircleAvatar(
                          radius: widget.size == GalleryIconSize.Big
                              ? 80
                              : widget.size == GalleryIconSize.Medium
                                  ? 60
                                  : widget.size == GalleryIconSize.Small
                                      ? 40
                                      : 80,
                          backgroundImage: FileImage(
                            widget.imageSrc!,
                          ),
                          backgroundColor: colorStyles['light_purple'],
                        )),
                  )),
          Positioned(
            right: -100,
            left: 0,
            bottom: widget.size == GalleryIconSize.Big
                ? 0
                : widget.size == GalleryIconSize.Medium
                    ? 0
                    : widget.size == GalleryIconSize.Small
                        ? 0
                        : 20,
            child: MaterialButton(
              onPressed: () => widget.onOpenGalleryOrCamera(),
              color: Colors.blue,
              textColor: Colors.white,
              child: Icon(
                Icons.camera_alt,
                size: 20,
              ),
              padding: EdgeInsets.all(16),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
