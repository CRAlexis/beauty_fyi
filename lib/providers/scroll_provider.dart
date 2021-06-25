import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class ScrollState {
  const ScrollState();
}

class ScrollInit extends ScrollState {
  final double elevation;
  const ScrollInit(this.elevation);
}

class ScrollNotifier extends StateNotifier<ScrollState> {
  final ScrollController _pageScrollController = ScrollController();
  ScrollNotifier([ScrollState? state]) : super(ScrollInit(0)) {
    _pageScrollController.addListener(_scrollListener);
  }

  bool _scrollIsActive = false;

  _scrollListener() {
    if (_pageScrollController.offset > 50 && !_scrollIsActive) {
      state = ScrollInit(20);
      _scrollIsActive = true;
    } else {
      if (_pageScrollController.offset < 50) {
        state = ScrollInit(0);
        _scrollIsActive = false;
      }
    }
  }

  ScrollController get scrollController {
    return _pageScrollController;
  }
}
