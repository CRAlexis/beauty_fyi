import 'dart:async';
import 'dart:convert';

import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final bool lastProcess;
  final bool vibrationSetting;

  const LiveSessionActive(
      this.serviceModel,
      this.sessionModel,
      this.processDurationInSeconds,
      this.sessionFinished,
      this.serviceProcess,
      this.lastProcess,
      this.vibrationSetting);
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

class LiveSessionErrorFatal extends LiveSessionState {
  final String message;
  const LiveSessionErrorFatal(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is LiveSessionErrorFatal && o.message == message;
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
  final storage = new FlutterSecureStorage();
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
      final serviceModel =
          await ServiceModel(id: sessionModel?.serviceId).readService();
      final allProcesses =
          jsonDecode(serviceModel.serviceProcesses as String) as List;
      final currentProcess = ServiceProcess()
          .toModel(allProcesses[sessionModel!.currentProcess as int]);

      int processDurationInSeconds =
          (currentProcess.processDuration as int) * 60;
      await dateTime.insertDateTime(
          newSessionOrNewProcess); // this does not run on first init

      final timeElapsed = DateTime.now()
          .difference((await dateTime.readDateTime()).dateTime
              as DateTime) // first date time is created here
          .inSeconds;

      print("time elapsed: $timeElapsed");

      processDurationInSeconds -= timeElapsed;
      sessionModel!.updateSession();
      state = LiveSessionActive(
          serviceModel,
          sessionModel as SessionModel,
          processDurationInSeconds,
          false,
          currentProcess,
          allProcesses.length - 1 == (sessionModel!.currentProcess as int),
          await storage.read(key: 'vibration_setting') == 'true');

      return;
    } catch (e) {
      try {
        print("error: $e");
        state =
            LiveSessionErrorFatal("Something has gone wrong with this session");
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
    try {
      final dateTimeModel =
          await DateTimeModel(meta: 'current_process_start_Time')
              .readDateTime();
      final int idleTime = DateTime.now()
          .difference((await DateTimeModel(meta: 'paused_time').readDateTime())
              .dateTime as DateTime)
          .inSeconds;
      print("current process: ${dateTimeModel.dateTime}");
      print("idle time: $idleTime");
      dateTimeModel.setDateTime =
          dateTimeModel.dateTime!.add(Duration(seconds: idleTime));
      await dateTimeModel.insertDateTime(true);
      await DateTimeModel(meta: 'paused_time').removeDateTime();
      await _fetchCurrentProcess(false);
    } catch (error) {
      state =
          LiveSessionErrorFatal("Something has gone wrong, please try again");
    }
  }

  void appResumed() async {
    try {
      final dateTimeModel =
          await DateTimeModel(meta: 'current_process_start_Time')
              .readDateTime();
      final timeElapsed = DateTime.now()
          .difference(dateTimeModel.dateTime as DateTime)
          .inSeconds;
      dateTimeModel.setDateTime =
          dateTimeModel.dateTime!.add(Duration(seconds: timeElapsed));
      await dateTimeModel.insertDateTime(true);
      await _fetchCurrentProcess(false);
    } catch (error) {
      state =
          LiveSessionErrorFatal("Something has gone wrong with this session");
    }
  }

  bool startNextProcessLock = false;
  Future<void> startNextProcess() async {
    try {
      if (!startNextProcessLock) {
        startNextProcessLock = true;
        sessionModel!.setCurrentProcess = sessionModel!.currentProcess! + 1;
        final serviceModel =
            await ServiceModel(id: sessionModel?.serviceId).readService();
        final allProcesses =
            jsonDecode(serviceModel.serviceProcesses as String) as List;
        if (allProcesses.length == sessionModel!.currentProcess) {
          return endSession();
        }
        await _fetchCurrentProcess(true);
        startNextProcessLock = false;
      }
      return;
    } catch (error) {
      state =
          LiveSessionErrorFatal("Something has gone wrong with this session");
    }
  }

  Future<void> onProcessFinished() async {
    try {
      _vibration();
    } catch (e) {
      print(e);
    }
  }

  Future<void> endSession() async {
    try {
      final serviceModel =
          await ServiceModel(id: sessionModel?.serviceId).readService();
      await sessionModel?.endSession();
      state = LiveSessionActive(
          serviceModel,
          sessionModel as SessionModel,
          0,
          true,
          ServiceProcess(processName: "session finished", processDuration: 0),
          false,
          await storage.read(key: 'vibration_setting') == 'true');
      await DateTimeModel(meta: 'paused_time').removeDateTime();
      return;
    } catch (e) {
      print(e);
      if (e is DioError) {
        state = LiveSessionErrorFatal(
          "Unable to end session. Please check you are connected to the internet.",
        );
        return;
      }
      state = LiveSessionErrorFatal("Unable to end session. Please try again.");
      return;
    }
  }

  void _vibration() async {
    if (await storage.read(key: 'vibration_setting') == 'true') {
      late Timer vibrationTimer;
      Vibration.cancel();
      int i = 0;
      vibrationTimer = new Timer.periodic(Duration(seconds: 1), (callback) {
        Vibration.vibrate(duration: 500);
        i++;
        i > 1 ? vibrationTimer.cancel() : false;
      });
    }
  }

  Future<void> updateNotes(String notes, SessionModel sessionModel) async {
    try {
      sessionModel.setNotes = notes;
      await sessionModel.updateSessionNotes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleVibration(value) async {
    await storage.write(
        key: 'vibration_setting', value: value ? 'true' : 'false');
    return;
  }
}
