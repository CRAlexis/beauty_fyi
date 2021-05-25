import 'dart:async';
import 'dart:io';

import 'package:beauty_fyi/models/service_media.dart';

enum GalleryEvent {
  PhotoCaptured,
  VideoCaptured,
}

class GalleryBloc {
  final _eventController = StreamController<Map<GalleryEvent, int>>();
  Stream<Map<GalleryEvent, int>> get eventStream => _eventController.stream;
  Sink<Map<GalleryEvent, int>> get eventSink => _eventController.sink;

  final _galleryController = StreamController<File>.broadcast();
  Stream<File> get galleryStream => _galleryController.stream;
  Sink<File> get gallerySink => _galleryController.sink;

  GalleryBloc() {
    eventStream.listen((Map<GalleryEvent, int> event) async {
      print("we here");
      final List<ServiceMedia> value = await ServiceMedia().readServiceMedia(
          sql: "session_id = ? AND file_type = ?",
          args: [event.values.first, 'image']);
      /*final List<ServiceMedia> all = await ServiceMedia()
          .readServiceMedia(sql: "session_id = ?", args: [event.values.first]);*/
      if (value.isNotEmpty) {
        gallerySink.add(File(value.last.filePath!));
      }
    });
  }
//
  void dipose() {
    _eventController.close();
    _galleryController.close();
  }
}

void a() {
  final galleryBloc = new GalleryBloc();
  galleryBloc._eventController.sink.add({GalleryEvent.PhotoCaptured: 1});
}
