import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class ProgressCircles extends StatefulWidget {
  final int circleAmount;
  final int currentIndex;
  const ProgressCircles({Key key, this.circleAmount, this.currentIndex})
      : super(key: key);
  @override
  _ProgressCirclesState createState() => _ProgressCirclesState();
}

class _ProgressCirclesState extends State<ProgressCircles> {
  @override
  Widget build(BuildContext context) {
    return (Align(
        alignment: Alignment.center,
        child: SizedBox(
            height: 25,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.circleAmount,
                itemBuilder: (context, index) {
                  return Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.circle,
                        color: index == widget.currentIndex
                            ? colorStyles['blue']
                            : Colors.grey.shade200,
                        size: 18,
                      ));
                }))));
  }
}
