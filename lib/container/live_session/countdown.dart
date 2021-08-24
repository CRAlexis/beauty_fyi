import 'dart:async';

import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/providers/liveSession/countdown_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final countdownNotifierProvider =
    StateNotifierProvider.autoDispose.family((ref, int params) {
  return CountdownNotifier(params);
});

class CountDown extends ConsumerWidget {
  final int _processDuration;
  final ServiceProcess _serviceProcess;
  final bool _sessionCompleted;
  final bool _lastProcess;
  final onPaused;
  final onResumed;
  final onStartNextProcess;
  final onProcessFinished;
  final VoidCallback? onShareMedia;
  CountDown(this._processDuration, this._serviceProcess, this._sessionCompleted,
      this._lastProcess,
      {this.onPaused,
      this.onResumed,
      this.onStartNextProcess,
      this.onProcessFinished,
      this.onShareMedia});
  Widget build(BuildContext context, ScopedReader watch) {
    //on state pause -> send to database -> or even callback to live session screen
    final state = watch(countdownNotifierProvider(_processDuration));
    print("## state: $state");
    final countdownNotifierController =
        context.read(countdownNotifierProvider(_processDuration).notifier);
    countdownNotifierController.processFinishedStream.listen((event) {
      if (event) {
        onProcessFinished();
      }
    });
    return Expanded(
      child: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: !_sessionCompleted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 6 + 0,
                  ),
                  Text(
                    _serviceProcess.processName as String,
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
                  state is CountdownActive || state is CountdownPaused
                      ? StreamBuilder<int>(
                          stream: state.stream,
                          initialData: null,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? Text(
                                    formatTime(snapshot.data as int),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.white,
                                        fontFamily: 'OpenSans'),
                                  )
                                : Container();
                          })
                      : Container(),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      state is! CountDownEnded
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MaterialButton(
                                  onPressed: () {
                                    state is CountdownActive //TODO:: put delay on how quickly they can switch
                                        ? () {
                                            countdownNotifierController
                                                .pauseCountdown();
                                            onPaused();
                                          }()
                                        : () {
                                            countdownNotifierController
                                                .resumeCountdown();
                                            onResumed();
                                          }();
                                  },
                                  child: state is CountdownPaused
                                      ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 40,
                                        )
                                      : state is CountdownActive
                                          ? Icon(
                                              Icons.pause,
                                              color: Colors.white,
                                              size: 40,
                                            )
                                          : CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : Container(),
                      state is! CountDownEnded
                          ? Text(
                              'or',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'OpenSans'),
                            )
                          : Container(),
                      TextButton(
                        onPressed: () async {
                          countdownNotifierController.endCountdown(false);
                          onStartNextProcess();
                          try {
                            print("process duration: $_processDuration");
                            countdownNotifierController
                                .refreshCountdown(_processDuration);
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              _lastProcess
                                  ? 'complete session'
                                  : 'start next process',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: state is CountDownEnded ? 24 : 17,
                                  color: Colors.white,
                                  fontFamily: 'OpenSans'),
                            )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Remember to capture your progress during the session',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontFamily: 'OpenSans'),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      OutlinedButton(
                          style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.white))),
                          onPressed: () => onShareMedia!(),
                          child: Text('Share media with client',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontFamily: 'OpenSans'))),
                    ],
                  )
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
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, "/dashboard", (r) => false),
                    child: Text(
                      "Return to dashboard",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
      )),
    );
  }
}

String formatTime(int timeInSeconds) {
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
