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
  const CountDownEnded();
}

class CountdownPaused extends CountdownState {
  final StreamController<int> controller;
  const CountdownPaused(this.controller);
  Stream<int> get stream => controller.stream;
}

class CountdownError extends CountdownState {
  final String message;
  const CountdownError(this.message);

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
    sessionFinishedController.add(false);
    initStream();
  }

  final controller = StreamController<int>.broadcast();
  final sessionFinishedController = StreamController<bool>.broadcast();
  void initStream() {
    state = CountdownActive(controller);
    Timer.periodic(Duration(seconds: 1), (timer) {
      try {
        if (!controller.isClosed && state is CountdownActive) {
          controller.sink.add(_count);
          _count--;
          if (_count == 0) {
            sessionFinishedController.add(true);
          }
        } else if (_count < 1) {
          controller.sink.add(0);
          controller.close();
        }
      } catch (e) {
        timer.cancel();
      }
    });
    state = CountdownActive(controller);
  }

  Stream<int> get stream => controller.stream;
  Stream<bool> get sessionFinishedStream => sessionFinishedController.stream;
  void closeStream() {
    controller.close();
    sessionFinishedController.close();
  }

  void pauseCountdown() => state = CountdownPaused(controller);
  void resumeCountdown() => state = CountdownActive(controller);
  void endCountdown() {
    state = CountDownEnded();
    _count = -1;
  }

  void refreshCountdown(int count) async {
    // await Future.delayed(Duration(seconds: 3));
    this._count = count;
    state = CountdownActive(controller);
  }

  void dispose() {
    controller.close();
    sessionFinishedController.close();
    super.dispose();
  }
}
