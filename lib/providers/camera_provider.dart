import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/service_media_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';

enum CameraEnum { LIVESESSION }

abstract class CameraState {
  const CameraState();
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraLoading extends CameraState {
  const CameraLoading();
}

class CameraLoaded extends CameraState {
  final CameraController cameraController;
  final bool cameraCaptureError;
  final String message;
  const CameraLoaded(
      this.cameraController, this.cameraCaptureError, this.message);
  // const CameraLoaded();
}

class CameraLoadingError extends CameraState {
  final String message;
  const CameraLoadingError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is CameraLoadingError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class CameraNotifier<CameraState> extends StateNotifier {
  final GalleryBloc galleryBloc;
  final CameraEnum cameraEnum;
  CameraNotifier(this.galleryBloc, this.cameraEnum, [CameraState? state])
      : super(CameraInitial()) {
    initCamera();
  }
  late CameraDescription camera;
  late CameraController cameraController;
  Future<void>? initialiseCameraControllerFuture;
  int cameraIndex = 0;

  Future<void> initCamera(
      {index = 0, cameraError = false, errorMessage = ''}) async {
    try {
      cameraIndex = index;
      state = CameraLoading();
      final cameras = await availableCameras();
      camera = cameras[index];
      cameraController = CameraController(camera, ResolutionPreset.high);
      await cameraController.initialize();
      await cameraController.unlockCaptureOrientation();
      // try {
      // await cameraController.setFlashMode(FlashMode.torch);
      // } catch (e) {
      // usually throws exception when the camera doesn't have flash (like a front camera)
      // print(e);
      // }
      state = CameraLoaded(cameraController, cameraError, errorMessage);
    } catch (e) {
      state = CameraLoadingError("Unable to load camera");
    }
  }

  Future<void> takePhoto(
    SessionModel sessionModel,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String name = DateTime.now().toString().replaceAll(" ", "");
      final path = "${directory.path}/$name.jpg";
      XFile file = await cameraController.takePicture();
      await file.saveTo(path);
      await FileAndImageFunctions().fixExifRotation(path);
      await new ServiceMedia(
              sessionId: sessionModel.id,
              serviceId: sessionModel.serviceId,
              fileType: "image",
              filePath: path,
              clientId: sessionModel.clientId)
          .insertServiceMedia(
        cameraEnum,
      );
      galleryBloc.eventSink.add(sessionModel.id as String);
    } catch (error) {
      if (error is DioError) {
        state = CameraLoaded(cameraController, true,
            "Unable to connect to the server. Please check your connection");
        return;
      }
      initCamera(
          index: 0,
          cameraError: true,
          errorMessage: 'Unable to take image, please try again');
    }
  }

  void startRecording() async {
    try {
      Vibration.vibrate(duration: 100);
      await cameraController.startVideoRecording();
    } catch (e) {
      initCamera(
          index: 0,
          cameraError: true,
          errorMessage: 'Unable to start recording, please try again');
    }
  }

  void stopRecording(
    SessionModel sessionModel,
  ) async {
    try {
      final d = await getExternalStorageDirectory();
      final String name = DateTime.now().toString().replaceAll(" ", "");
      final directory =
          d != null ? d : await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$name.mp4";
      XFile file = await cameraController.stopVideoRecording();

      await file.saveTo(path);
      await ServiceMedia(
              sessionId: sessionModel.id,
              serviceId: sessionModel.serviceId,
              fileType: "video",
              filePath: path,
              clientId: sessionModel.clientId)
          .insertServiceMedia(
        cameraEnum,
      );
      galleryBloc.eventSink.add(sessionModel.id as String);
    } catch (error) {
      initCamera(
          index: 0,
          cameraError: true,
          errorMessage: 'Unable to save recording, please try again');
    }
  }

  Future<void> setZoom(double val) async {
    try {
      double zoom = pow(val, 2.718281828459045).toDouble();
      double max = await cameraController.getMaxZoomLevel();
      await cameraController.setZoomLevel(zoom < 1
          ? 1
          : zoom > max
              ? max
              : zoom);
    } catch (e) {
      print("zoom: $e");
    }
  }

  void dispose() async {
    await cameraController.dispose();
    super.dispose();
  }
}
