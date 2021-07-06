import 'package:beauty_fyi/bloc/gallery_bloc.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vibration/vibration.dart';

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
  const CameraLoaded(this.cameraController);
  // const CameraLoaded();
}

class CameraCaptureError extends CameraState {
  final CameraController cameraController;
  final String message;
  const CameraCaptureError(this.cameraController, this.message);
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
  CameraNotifier(this.galleryBloc, [CameraState? state])
      : super(CameraInitial()) {
    initCamera();
  }
  late CameraDescription camera;
  late CameraController cameraController;
  Future<void>? initialiseCameraControllerFuture;
  int cameraIndex = 0;

  Future<void> initCamera({index = 0}) async {
    try {
      cameraIndex = index;
      state = CameraLoading();
      final cameras = await availableCameras();
      camera = cameras[index];
      cameraController = CameraController(camera, ResolutionPreset.high);
      await cameraController.initialize();
      // try {
      // await cameraController.setFlashMode(FlashMode.torch);
      // } catch (e) {
      // usually throws exception when the camera doesn't have flash (like a front camera)
      // print(e);
      // }
      state = CameraLoaded(cameraController);
    } catch (e) {
      state = CameraLoadingError("Unable to load camera");
    }
  }

  Future<void> takePhoto(
    SessionModel sessionModel,
  ) async {
    try {
      state = CameraLoaded(cameraController);
      // state = CameraLoaded(cameraController);
      print("# take photo");
      final directory = await getApplicationDocumentsDirectory();
      final String name = DateTime.now().toString().replaceAll(" ", "");
      final path = "${directory.path}/$name.png";
      XFile file = await cameraController.takePicture();
      print("# ${file.path}");
      file.saveTo(path);
      await ServiceMedia().insertServiceMedia(ServiceMedia(
          sessionId: sessionModel.id,
          serviceId: sessionModel.serviceId,
          fileType: "image",
          filePath: path,
          clientId: sessionModel.clientId));
      galleryBloc.eventSink.add(sessionModel.id as int);
    } catch (error) {
      print("# $error");
      state = CameraCaptureError(cameraController, "Unable to take image.");
    }
  }

  void startRecording() async {
    print("# start recording");
    try {
      // state = CameraLoaded(cameraController);
      // state = CameraLoaded(cameraController);
      Vibration.vibrate(duration: 100);
      await cameraController.startVideoRecording();
    } catch (e) {
      state = CameraCaptureError(cameraController, "Unable to save video.");
    }
  }

  void stopRecording(
    SessionModel sessionModel,
  ) async {
    print("# end recording");
    try {
      print("# 1");
      final d = await getExternalStorageDirectory();
      final String name = DateTime.now().toString().replaceAll(" ", "");
      final directory =
          d != null ? d : await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$name.mp4";
      print("# 2");

      XFile file = await cameraController.stopVideoRecording();
      print("# 3");

      file.saveTo(path);
      await ServiceMedia().insertServiceMedia(ServiceMedia(
          sessionId: sessionModel.id,
          serviceId: sessionModel.serviceId,
          fileType: "video",
          filePath: path));
      print("# 4");

      galleryBloc.eventSink.add(sessionModel.id as int);
      print("# 5");
    } catch (error) {
      state = CameraCaptureError(cameraController, "Unable to save video.");
      print(error);
    }
  }

  void dispose() async {
    await cameraController.dispose();
    super.dispose();
  }
}
