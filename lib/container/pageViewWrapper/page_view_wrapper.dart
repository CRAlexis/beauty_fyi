import 'package:flutter/material.dart';

class PageViewWrapper extends StatefulWidget {
  final bool keepAlive;
  final Widget child;
  const PageViewWrapper(
      {Key? key, required this.child, required this.keepAlive})
      : super(key: key);

  @override
  _PageViewWrapperState createState() => _PageViewWrapperState();
}

class _PageViewWrapperState extends State<PageViewWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
