import 'dart:async';
import 'dart:convert';

import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vibration/vibration.dart';

abstract class LiveSessionState {
  const LiveSessionState();
}

class LiveSessionInitial extends LiveSessionState {
  const LiveSessionInitial();
}

class LiveSessionLoading extends LiveSessionState {
  const LiveSessionLoading();
}

class LiveSessionActive extends LiveSessionState {
  //here will have process information, session information, service information etc
  final ServiceModel serviceModel;
  final SessionModel sessionModel;
  final int processDurationInSeconds;
  final bool sessionFinished;
  final ServiceProcess serviceProcess;

  const LiveSessionActive(this.serviceModel, this.sessionModel,
      this.processDurationInSeconds, this.sessionFinished, this.serviceProcess);
}

class LiveSessionError extends LiveSessionState {
  final String message;
  const LiveSessionError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is LiveSessionError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class LiveSessionNotifier<LiveSessionState> extends StateNotifier {
  final SessionModel? sessionModel;
  LiveSessionNotifier(this.sessionModel, [LiveSessionState? state])
      : super(LiveSessionLoading()) {
    countdownResumed();
  }
  List<Color> backgroundColors = [
    colorStyles['dark_purple'] as Color,
    colorStyles['light_purple'] as Color,
    colorStyles['blue'] as Color,
    colorStyles['green'] as Color
  ];

  Future<void> _fetchCurrentProcess(bool newSessionOrNewProcess) async {
    final DateTimeModel dateTime = DateTimeModel(
        dateTime: DateTime.now(), meta: 'current_process_start_Time');
    try {
      // print("#1");
      final serviceModel =
          await ServiceModel(id: sessionModel?.serviceId).readService();
      // print("#2");

      final allProcesses =
          jsonDecode(serviceModel.serviceProcesses as String) as List;
      final currentProcess = ServiceProcess()
          .toModel(allProcesses[sessionModel!.currentProcess as int]);
      // print("#3");
      // print("process length: ${allProcesses.length}");
      // print("current process: ${sessionModel!.currentProcess}");
      if (allProcesses.length == sessionModel!.currentProcess) {
        print("end the session");
        return endSession();
      }
      // print("#4");

      int processDurationInSeconds =
          (currentProcess.processDuration as int) * 60;
      // print("#5");

      await dateTime.insertDateTime(
          newSessionOrNewProcess); // this does not run on first init

      final timeElapsed = DateTime.now()
          .difference((await dateTime.readDateTime()).dateTime
              as DateTime) // first date time is created here
          .inSeconds;

      // print("#6");

      processDurationInSeconds -= timeElapsed;
      sessionModel!.updateSession();
      // print("#7");

      state = LiveSessionActive(serviceModel, sessionModel as SessionModel,
          processDurationInSeconds, false, currentProcess);
      // print("#8");

      return;
    } catch (e) {
      try {
        print("error: $e");
        state = LiveSessionError("Something has gone wrong with this session");
        await dateTime.removeDateTime();
        await sessionModel?.endSession();
      } catch (e) {}
    }
  }

  Future<void> countdownPaused() async {
    await DateTimeModel(dateTime: DateTime.now(), meta: 'paused_time')
        .insertDateTime(true);
  }

  Future<void> countdownResumed() async {
    final dateTimeModel =
        await DateTimeModel(meta: 'current_process_start_Time').readDateTime();
    final int idleTime = DateTime.now()
        .difference((await DateTimeModel(meta: 'paused_time').readDateTime())
            .dateTime as DateTime)
        .inSeconds;
    dateTimeModel.setDateTime =
        dateTimeModel.dateTime!.add(Duration(seconds: idleTime));
    await dateTimeModel.insertDateTime(true);
    await DateTimeModel(meta: 'paused_time').removeDateTime();
    await _fetchCurrentProcess(false);
  }

  void appResumed() async {
    final dateTimeModel =
        await DateTimeModel(meta: 'current_process_start_Time').readDateTime();
    final timeElapsed =
        DateTime.now().difference(dateTimeModel.dateTime as DateTime).inSeconds;
    dateTimeModel.setDateTime =
        dateTimeModel.dateTime!.add(Duration(seconds: timeElapsed));
    await dateTimeModel.insertDateTime(true);
    await _fetchCurrentProcess(false);
  }

  bool startNextProcessLock = false;
  Future<void> startNextProcess() async {
    if (!startNextProcessLock) {
      startNextProcessLock = true;
      sessionModel!.setCurrentProcess = sessionModel!.currentProcess! + 1;
      await _fetchCurrentProcess(true);
      startNextProcessLock = false;
    }
    return;
  }

  Future<void> endCurrentProcess() async {
    try {
      backgroundColors = [
        colorStyles['darker_green'] as Color,
        colorStyles['green'] as Color,
        colorStyles['blue'] as Color,
        colorStyles['green'] as Color
      ];
      _vibration();
      await DateTimeModel(
        dateTime: DateTime.now(),
        meta: 'current_process_start_Time',
      ).insertDateTime(true);
      return;
    } catch (e) {
      print(e);
    }
  }

  Future<void> endSession() async {
    final serviceModel =
        await ServiceModel(id: sessionModel?.serviceId).readService();
    await sessionModel!.endSession();
    state = LiveSessionActive(
        serviceModel,
        sessionModel as SessionModel,
        0,
        true,
        ServiceProcess(processName: "session finished", processDuration: 0));
    await DateTimeModel(meta: 'paused_time').removeDateTime();
    return;
  }

  void _vibration() {
    late Timer vibrationTimer;
    Vibration.cancel();
    int i = 0;
    vibrationTimer = new Timer.periodic(Duration(seconds: 1), (callback) {
      Vibration.vibrate(duration: 500);
      i++;
      i > 1 ? vibrationTimer.cancel() : false;
    });
  }

  void updateNotes(String notes) {
    sessionModel!.setNotes = notes;
    sessionModel!.updateSession();
  }
}
