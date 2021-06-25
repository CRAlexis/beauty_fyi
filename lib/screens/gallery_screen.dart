import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/media/grid_media.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  final args;
  GalleryScreen({this.args});
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          images: widget.args['media'],
        ));
  }
}

Future<List<ServiceMedia>> fetchImages(
    {required SessionModel sessionModel}) async {
  return await ServiceMedia()
      .readServiceMedia(sql: "session_id = ?", args: [sessionModel.id]);
}
