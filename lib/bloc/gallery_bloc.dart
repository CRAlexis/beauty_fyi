import 'dart:async';

import 'package:beauty_fyi/models/service_media_model.dart';
import 'package:beauty_fyi/models/session_model.dart';

enum GalleryEvent {
  PhotoCaptured,
}

class GalleryBloc {
  final _eventController = StreamController<String>();
  Stream<String> get eventStream => _eventController.stream;
  Sink<String> get eventSink => _eventController.sink;

  // final _galleryController = StreamController<File>.broadcast();
  // Stream<List<File> get galleryStream => _galleryController.stream;
  // Sink<File> get gallerySink => _galleryController.sink;

  final _serviceMediaController = StreamController<ServiceMedia>.broadcast();
  Stream<ServiceMedia> get serviceMediaStream => _serviceMediaController.stream;
  Sink<ServiceMedia> get serviceMediaSink => _serviceMediaController.sink;
  //https://pub.dev/packages/video_thumbnail

  Future<void> init(String sessionId) async {
    try {
      await serviceMediaStream.drain();
      final List<ServiceMedia> images = await ServiceMedia().readServiceMedia(
          sql: "session_id = ? AND file_type = ?", args: [sessionId, 'image']);
      for (final image in images) {
        serviceMediaSink.add(image);
      }
    } catch (e) {}
  }

  final SessionModel? sessionModel;
  GalleryBloc(this.sessionModel) {
    sessionModel != null
        ? () {
            init(sessionModel!.id as String);
            eventStream.listen((String sessionId) async {
              final List<ServiceMedia> images = await ServiceMedia()
                  .readServiceMedia(sql: "session_id = ?", args: [sessionId]);
              images.isNotEmpty ? serviceMediaSink.add(images.last) : false;
            });
          }()
        : null;
  }
//
  void dipose() {
    _eventController.close();
    _serviceMediaController.close();
  }
}
