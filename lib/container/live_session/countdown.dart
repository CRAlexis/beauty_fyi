import 'dart:async';
import 'dart:convert';

import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CountDown extends StatefulWidget {
  final secondCallBack;
  final sessionFinished;
  final startingNextProcess;
  final SessionModel? sessionModel;
  CountDown(
      {this.secondCallBack,
      this.sessionFinished,
      this.startingNextProcess,
      this.sessionModel});
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<CountDown> {
  Duration timerDuration = Duration(seconds: 1);
  DateTime? pausedTime;
  Tween<double>? tween;
  late Timer timer;
  String? formattedTime;
  late String processName;
  late int timeInSeconds = -2;
  late int processTimeInSeconds;
  int processIndex = 0; // Will need to fetch this from database
  bool timerIsPaused = false;
  bool processFinished = false;
  bool sessionFinished = false;
  bool startNextProcessLock = false;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();

    start();
    WidgetsBinding.instance!.addObserver(this);
  }

  void start() async {
    processIndex = widget.sessionModel?.currentProcess as int;
    await fetchServiceData(overwrite: false);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      WidgetsBinding.instance!.removeObserver(this);
      timer.cancel();
    } catch (e) {}
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
    final timeElapsed = now.difference(value.dateTime as DateTime).inSeconds;
    timeInSeconds = processTimeInSeconds - timeElapsed;
  }

  // will need to do some sort of error catching in this function
  // This function does not run on app resume
  Future<void> fetchServiceData({required bool overwrite, int debt = 0}) async {
    final serviceModel = new ServiceModel(id: widget.sessionModel!.serviceId);
    final service = await serviceModel.readService();
    final dateTime =
        DateTimeModel(dateTime: DateTime.now(), className: 'countdown');
    List<Map<String, dynamic>>? processes =
        (jsonDecode(service.serviceProcesses as String) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    print(
        "#A proccess length: ${processes.length}, current: ${widget.sessionModel!.currentProcess}");
    if (processes.length == widget.sessionModel!.currentProcess) {
      widget.sessionFinished();
      sessionFinished = true;
      widget.sessionModel!.setActive = false;
      await widget.sessionModel!.endSession();
      return;
    } else {
      processName = processes[widget.sessionModel!.currentProcess!].keys.first;
      timeInSeconds =
          processes[widget.sessionModel!.currentProcess!].values.first * 60;
      processTimeInSeconds =
          processes[widget.sessionModel!.currentProcess!].values.first * 60;
      await widget.sessionModel!.updateSession(widget.sessionModel!);

      await dateTime.insertDateTime(
          dateTimeModel: dateTime, overwrite: overwrite);
      final value = await dateTime.readDateTime();
      if (value.dateTime == null) {
        //first time its running
        return;
      }
      final timeElapsed = DateTime.now().difference(value.dateTime!).inSeconds;
      print("#A timeElapsed: $timeElapsed");
      timeInSeconds = processTimeInSeconds - timeElapsed;
      timeInSeconds -= debt;
      return;
    }
  }

  void countdownTimer() async {
    if (!timerIsPaused) {
      if (pausedTime != null) {
        DateTimeModel dateTimeModel =
            await DateTimeModel(className: 'countdown').readDateTime();
        final pausedDifference =
            DateTime.now().difference(pausedTime!).inSeconds;
        dateTimeModel.setDateTime =
            dateTimeModel.dateTime!.add(Duration(seconds: pausedDifference));
        await dateTimeModel.insertDateTime(
            dateTimeModel: dateTimeModel, overwrite: true);
        pausedTime = null;
      }
      if (timeInSeconds > 0) {
        timer = new Timer(timerDuration, () {
          if (!timerIsPaused) {
            timeInSeconds--;
            timeInSeconds < 0 ? null : widget.secondCallBack(timeInSeconds);
            timer.cancel();
            setState(() {
              formattedTime = formatTime(timeInSeconds);
            });
          }
        });
      } else {
        await startNextProcess();
        setState(() {});
      }
    } else {
      if (pausedTime == null) {
        pausedTime = DateTime.now();
      }
    }
  }

  void vibration() {
    late Timer vibrationTimer;
    Vibration.cancel();
    int i = 0;
    vibrationTimer = new Timer.periodic(Duration(seconds: 1), (callback) {
      Vibration.vibrate(duration: 500);
      i++;
      i > 1 ? vibrationTimer.cancel() : false;
    });
  }

  Future<void> startNextProcess() async {
    if (!sessionFinished && timeInSeconds < 1 && !startNextProcessLock) {
      startNextProcessLock = true;
      print("#A debt: $timeInSeconds");
      vibration();
      widget.sessionModel!.setCurrentProcess =
          widget.sessionModel!.currentProcess! + 1;
      await fetchServiceData(overwrite: true, debt: timeInSeconds);
      widget.startingNextProcess();
      startNextProcessLock = false;
    }
    return;
  }

  Future<void> endCurrentProcess() async {
    try {
      timerIsPaused = false;
      DateTimeModel dateTimeModel = DateTimeModel(
          className: 'countdown',
          dateTime: DateTime.now().subtract(Duration(seconds: timeInSeconds)));
      timeInSeconds = 0;
      await dateTimeModel.insertDateTime(
          dateTimeModel: dateTimeModel, overwrite: true);
      return;
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (timeInSeconds == -2) {
      return CountDownRefresh(
        refresher: () {
          setState(() {});
        },
      );
    } // this may have broken - cause i did not use else
    countdownTimer();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: !sessionFinished
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5 + 0,
                ),
                Text(
                  processName,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: 'OpenSans'),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 0.5,
                  indent: 60,
                  endIndent: 60,
                ),
                formattedTime != "0"
                    ? Text(
                        formattedTime == null ? "" : formattedTime!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 45,
                            color: Colors.white,
                            fontFamily: 'OpenSans'),
                      )
                    : Text(
                        formattedTime == null ? "" : "0", //if time is 0
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 45,
                            color: Colors.white,
                            fontFamily: 'OpenSans'),
                      ),
                SizedBox(
                  height: 30,
                ),
                Column(
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
                      onPressed: () async {
                        timerIsPaused = false;
                        await endCurrentProcess();
                        setState(() {});
                      },
                      child: Text(
                        'start next process',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontFamily: 'OpenSans'),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Remeber to capture your progress during the session',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'OpenSans'),
                    ),
                  ],
                )
                /*Column(
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
                            onPressed: () async {
                              await startNextProcess();
                              setState(() {});
                            },
                            child: Text(
                              "CONTINUE",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ) */
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                ),
                Text(
                  "Session completed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'OpenSans'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.white)),
                      minimumSize: MaterialStateProperty.all(Size(200, 35))),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Finish",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}

class CountDownRefresh extends StatelessWidget {
  final refresher;
  CountDownRefresh({this.refresher});
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((value) {
      refresher();
    });
    return SizedBox();
  }
}

String formatTime(timeInSeconds) {
  if (timeInSeconds <= 0) {
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
