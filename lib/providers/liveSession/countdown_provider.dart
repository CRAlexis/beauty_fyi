import 'dart:async';

import 'package:riverpod/riverpod.dart';

abstract class CountdownState {
  const CountdownState();
}

class CountdownInitial extends CountdownState {
  CountdownInitial();
}

class CountdownLoading extends CountdownState {
  const CountdownLoading();
}

class CountdownActive extends CountdownState {
  final StreamController<int> controller;
  const CountdownActive(this.controller);
  Stream<int> get stream => controller.stream;
}

class CountDownEnded extends CountdownState {
  final StreamController<int> controller;

  const CountDownEnded(this.controller);
  Stream<int> get stream => controller.stream;
}

class CountdownPaused extends CountdownState {
  final StreamController<int> controller;
  const CountdownPaused(this.controller);
  Stream<int> get stream => controller.stream;
}

class CountdownError extends CountdownState {
  final String message;
  final StreamController<int> controller;

  const CountdownError(this.message, this.controller);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is CountdownError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class CountdownNotifier<CountdownState> extends StateNotifier {
  int _count;
  CountdownNotifier(this._count, [CountdownState? state])
      : super(CountdownInitial()) {
    processFinishedController.add(false);
    initStream();
  }

  final controller = StreamController<int>.broadcast();
  final processFinishedController = StreamController<bool>.broadcast();

  void initStream() {
    state = CountdownActive(controller);
    if (_count < 1) {
      endCountdown(false);
      return;
    }

    Timer.periodic(Duration(seconds: 1), (timer) {
      try {
        if (!controller.isClosed && state is CountdownActive) {
          if (_count < 1) {
            state is! CountDownEnded ? endCountdown(true) : null;
            timer.cancel();
            // controller.close();
            return;
          }
          controller.sink.add(_count);
          _count--;
        }
      } catch (e) {
        state = CountdownError("error", controller);
        timer.cancel();
      }
    });
  }

  Stream<int> get stream => controller.stream;
  Stream<bool> get processFinishedStream => processFinishedController.stream;
  void closeStream() {
    controller.close();
    processFinishedController.close();
  }

  void pauseCountdown() => state = CountdownPaused(controller);
  void resumeCountdown() => state = CountdownActive(controller);
  void endCountdown(bool vibrate) {
    state = CountDownEnded(controller);
    processFinishedController.add(vibrate);
  }

  void refreshCountdown(int count) async {
    this._count = count;
    initStream();
  }

  void dispose() {
    controller.close();
    processFinishedController.close();
    super.dispose();
  }
}
