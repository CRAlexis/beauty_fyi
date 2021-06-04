import 'dart:async';

class NumberCreator {
  NumberCreator() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!controller.isClosed) {
        controller.sink.add(_count);
        _count++;
      }
    });
  }

  int _count = 1;
  final controller = StreamController<int>();
  Stream<int> get stream => controller.stream;
}
