import 'package:flutter/material.dart';

class SlideFromBottomTransition extends StatelessWidget {
  final Widget child;
  final AnimationController? controller;
  final bool? visible;
  SlideFromBottomTransition({
    required this.child,
    required this.controller,
    required this.visible,
  });
  @override
  Widget build(BuildContext context) {
    visible! ? controller!.reverse() : controller!.forward();
    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: Offset(0, 1.0)).animate(
        CurvedAnimation(parent: controller!, curve: Curves.fastOutSlowIn),
      ),
      child: child,
    );
  }
}
