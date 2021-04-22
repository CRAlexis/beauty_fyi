import 'dart:async';

import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  final int timeInSeconds;
  final String processName;
  final secondCallBack;
  final processIsFinished;
  CountDown(
      {this.timeInSeconds,
      this.processName = "",
      this.secondCallBack,
      this.processIsFinished});
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<CountDown> {
  int timeInSeconds;
  String formattedTime;
  Timer timer;
  bool timerIsPaused = false;
  Duration timerDuration = Duration(seconds: 1);
  Tween<double> tween;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timeInSeconds = widget.timeInSeconds;
    final dateTime =
        DateTimeModel(dateTime: DateTime.now(), className: 'countdown');
    dateTime
        .insertDateTime(dateTimeModel: dateTime, overwrite: true)
        .then((value) {
      dateTime.readDateTime().then((value) {
        if (value.dateTime == null) {
          return;
        }
        final now = DateTime.now();
        final timeElapsed = now.difference(value.dateTime).inSeconds;
        timeInSeconds -= timeElapsed;
      });
    });
  }

  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state.toString()) {
      case 'AppLifecycleState.paused':
        break;
      case 'AppLifecylcleState.inactive':
        break;
      case 'AppLifecycleState.resumed':
        appResumed();
        break;
      default:
    }
  }

  void appResumed() async {
    final dateTime = DateTimeModel(className: 'countdown');
    final value = await dateTime.readDateTime();
    final now = DateTime.now();
    final timeElapsed = now.difference(value.dateTime).inSeconds;
    timeInSeconds = widget.timeInSeconds - timeElapsed;
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (!timerIsPaused && timeInSeconds > 0) {
      timer = new Timer(timerDuration, () {
        if (!timerIsPaused) {
          timeInSeconds--;
          timeInSeconds < 0
              ? timeInSeconds = 0
              : widget.secondCallBack(timeInSeconds);
          timer.cancel();
          setState(() {
            formattedTime = formatTime(timeInSeconds);
          });
        }
      });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 5 + 0,
          ),
          Text(
            formattedTime == null ? "" : formattedTime,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 70, color: Colors.white, fontFamily: 'OpenSans'),
          ),
          Divider(
            color: Colors.white,
            thickness: 0.5,
            indent: 60,
            endIndent: 60,
          ),
          Text(
            widget.processName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontFamily: 'OpenSans'),
          ),
          SizedBox(
            height: 50,
          ),
          timeInSeconds > 1
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              timerIsPaused = !timerIsPaused;
                            });
                          },
                          child: timerIsPaused
                              ? Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 40,
                                ),
                        ),
                      ],
                    ),
                    Text(
                      'or',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'OpenSans'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          timeInSeconds = 0;
                        });
                      },
                      child: Text(
                        'end this process',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontFamily: 'OpenSans'),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      'Capture your progress then continue to the next process',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'OpenSans'),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.white)),
                          minimumSize:
                              MaterialStateProperty.all(Size(200, 35))),
                      onPressed: null,
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}

String formatTime(timeInSeconds) {
  if (timeInSeconds == 0) {
    return '0';
  }
  final hours = (timeInSeconds / 3600).floor();
  final minutes = (timeInSeconds / 60 % 60).floor();
  final seconds = (timeInSeconds % 60);
  String formattedString = "";
  if (hours != 0) {
    formattedString += hours.toString().padLeft(2, '0') + ":";
  }
  if (minutes != 0) {
    formattedString += minutes.toString().padLeft(2, '0') + ":";
  }
  formattedString += seconds.toString().padLeft(2, '0');
  return formattedString;
}
