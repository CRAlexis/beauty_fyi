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
    print("countdown provider initialised**");
    initStream();
  }

  final controller = StreamController<int>.broadcast();
  void initStream() {
    state = CountdownActive(controller);
    Timer.periodic(Duration(seconds: 1), (timer) {
      try {
        if (!controller.isClosed && state is CountdownActive) {
          controller.sink.add(_count);
          _count--;
        }
      } catch (e) {
        timer.cancel();
      }
    });
    state = CountdownActive(controller);
  }

  Stream<int> get stream => controller.stream;
  void closeStream() {
    controller.close();
  }

  void pauseCountdown() => state = CountdownPaused(controller);
  void resumeCountdown() => state = CountdownActive(controller);
  void endCountdown() {
    state = CountDownEnded();
    _count = 0;
  }

  void refreshCountdown(int count) async {
    // await Future.delayed(Duration(seconds: 3));
    this._count = count;
    state = CountdownActive(controller);
  }
}
