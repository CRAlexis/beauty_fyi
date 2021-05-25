import 'package:beauty_fyi/container/transitions/slide_from_bottom.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final bool? visble;
  final AnimationController? controller;
  final deleteImage;
  final openCamera;
  final openGallery;
  const BottomBar(
      {Key? key,
      this.visble,
      this.controller,
      this.deleteImage,
      this.openCamera,
      this.openGallery})
      : super(key: key);
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: SlideFromBottomTransition(
          visible: widget.visble,
          controller: widget.controller,
          child: Container(
              height: 115,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: colorStyles['dark_blue_grey']),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Service image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          child: Icon(
                            Icons.delete,
                            size: 22,
                          ),
                          padding: EdgeInsets.all(14),
                          shape: CircleBorder(),
                          onPressed: () => widget.deleteImage(),
                        ),
                        MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 22,
                          ),
                          padding: EdgeInsets.all(14),
                          shape: CircleBorder(),
                          onPressed: () => widget.openCamera(),
                        ),
                        MaterialButton(
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          child: Icon(
                            Icons.photo,
                            size: 22,
                          ),
                          padding: EdgeInsets.all(14),
                          shape: CircleBorder(),
                          onPressed: () => widget.openGallery(),
                        ),
                      ],
                    )
                  ])),
        ));
  }
}
