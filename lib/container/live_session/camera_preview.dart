import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;
  final Future<void> initialiseCameraControllerFuture;
  CameraPreviewScreen(
      {this.cameraController, this.initialiseCameraControllerFuture});
  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen>
    with AutomaticKeepAliveClientMixin<CameraPreviewScreen> {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: widget.initialiseCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(widget.cameraController);
          } else {
            return Text("");
          }
        });
  }
}
