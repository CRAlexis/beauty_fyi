import 'dart:async';

import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';

enum GalleryEvent {
  PhotoCaptured,
}

class GalleryBloc {
  final _eventController = StreamController<int>();
  Stream<int> get eventStream => _eventController.stream;
  Sink<int> get eventSink => _eventController.sink;

  // final _galleryController = StreamController<File>.broadcast();
  // Stream<List<File> get galleryStream => _galleryController.stream;
  // Sink<File> get gallerySink => _galleryController.sink;

  final _serviceMediaController = StreamController<ServiceMedia>.broadcast();
  Stream<ServiceMedia> get serviceMediaStream => _serviceMediaController.stream;
  Sink<ServiceMedia> get serviceMediaSink => _serviceMediaController.sink;
  //https://pub.dev/packages/video_thumbnail

  Future<void> init(int sessionId) async {
    await serviceMediaStream.drain();
    final List<ServiceMedia> images = await ServiceMedia().readServiceMedia(
        sql: "session_id = ? AND file_type = ?", args: [sessionId, 'image']);
    for (final image in images) {
      serviceMediaSink.add(image);
    }
  }

  final SessionModel? sessionModel;
  GalleryBloc(this.sessionModel) {
    sessionModel != null
        ? () {
            init(sessionModel!.id as int);
            eventStream.listen((int sessionId) async {
              final List<ServiceMedia> images = await ServiceMedia()
                  .readServiceMedia(
                      sql: "session_id = ? AND file_type = ?",
                      args: [sessionId, 'image']);
              serviceMediaSink.add(images.last);
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
