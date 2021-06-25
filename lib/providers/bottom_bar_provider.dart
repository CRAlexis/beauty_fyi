import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BottomBarState {
  const BottomBarState();
}

class BottomBarVisibility extends BottomBarState {
  final bool isVisible;
  const BottomBarVisibility(this.isVisible);
}

class BottomBarNotifier<BottomBarState> extends StateNotifier {
  BottomBarNotifier([BottomBarState? state])
      : super(BottomBarVisibility(false));

  bool isVisible = false;
  Future<void> showBottomBar() async {
    isVisible = true;
    state = BottomBarVisibility(isVisible);
    return;
  }

  Future<void> hideBottomBar() async {
    isVisible = false;
    state = BottomBarVisibility(isVisible);
    return;
  }
}
