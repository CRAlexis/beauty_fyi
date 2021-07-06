import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/media/grid_media.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  final args;
  GalleryScreen({this.args});
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorStyles['cream'],
        appBar: CustomAppBar(
            focused: true,
            transparent: false,
            titleText: "Gallery",
            leftIcon: Icons.arrow_back,
            showMenuIcon: false,
            leftIconClicked: () {
              Navigator.pop(context);
            },
            automaticallyImplyLeading: false),
        body: GridMedia(
          images: args['media'],
        ));
  }
}
