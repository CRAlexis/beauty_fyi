import 'dart:io';

import 'package:flutter/material.dart';

class GalleryIconStack extends StatefulWidget {
  final File imageSrc;
  final onPreviewImage;
  final onOpenGalleryOrCamera;
  const GalleryIconStack(
      {Key key, this.imageSrc, this.onPreviewImage, this.onOpenGalleryOrCamera})
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
                  height: 200,
                  onPressed: () => widget.onPreviewImage(),
                  color: Colors.grey.shade200,
                  textColor: Colors.white,
                  child: Icon(
                    Icons.image,
                    size: 80,
                  ),
                  padding: EdgeInsets.all(36),
                  shape: CircleBorder(),
                  elevation: 0,
                )
              : GestureDetector(
                  onTap: () => widget.onPreviewImage(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Hero(
                        tag: "full_screen_image_hero",
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(
                            widget.imageSrc,
                          ),
                        )),
                  )),
          Positioned(
            right: -100,
            left: 0,
            bottom: 20,
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
