import 'dart:async';

enum FullScreenMediaEvent {
  VideoPlayState,
  VideoPauseState,
  OverlayState,
}

class FullScreenMediaBloc {
  final _eventController = StreamController<FullScreenMediaEvent>.broadcast();
  Stream<FullScreenMediaEvent> get eventStream => _eventController.stream;
  Sink<FullScreenMediaEvent> get eventSink => _eventController.sink;

  final _videoPlayPauseStateController = StreamController<bool>.broadcast();
  Stream<bool> get videoPlayPauseStateStream =>
      _videoPlayPauseStateController.stream;
  Sink<bool> get videoPlayPauseStateSink => _videoPlayPauseStateController.sink;

  final _overlayStateController = StreamController<bool>();
  Stream<bool> get overlayStateStream => _overlayStateController.stream;
  Sink<bool> get overlayStateSink => _overlayStateController.sink;

  bool videoPlayState = true;
  bool overlayState = false;

  FullScreenMediaBloc() {
    eventStream.listen((event) {
      switch (event) {
        case FullScreenMediaEvent.VideoPlayState:
          videoPlayState = true;
          videoPlayPauseStateSink.add(videoPlayState);
          break;
        case FullScreenMediaEvent.VideoPauseState:
          videoPlayState = false;
          videoPlayPauseStateSink.add(videoPlayState);
          break;
        case FullScreenMediaEvent.OverlayState:
          overlayState = !overlayState;
          _overlayStateController.add(overlayState);
          break;
        default:
          break;
      }
    });
  }

  void dispose() {
    _eventController.close();
    _videoPlayPauseStateController.close();
  }
}
