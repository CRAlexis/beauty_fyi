import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/client_list_alert_dialog.dart';
import 'package:beauty_fyi/models/datetime_model.dart';
import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

enum SessionProviderEnums { READBUNDLE, NULL }

abstract class SessionsState {
  const SessionsState();
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  const SessionsLoaded();
}

class SessionBundleLoaded extends SessionsState {
  final SessionBundleModel sessionBundle;
  const SessionBundleLoaded(this.sessionBundle);
}

class SessionsError extends SessionsState {
  final String message;
  const SessionsError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is SessionsError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  SessionsNotifier(SessionProviderEnums providerEnums, String? clientId,
      [SessionsState? state])
      : super(SessionsInitial()) {
    switch (providerEnums) {
      case SessionProviderEnums.READBUNDLE:
        getSessionBundle(clientId);
        break;
      default:
    }
  }

  Future<void> getSessionBundle(clientId) async {
    try {
      state = SessionsLoading();
      final sessionBundle = await SessionModel(
        clientId: clientId,
      ).readSessions(sql: "client_id = ?", args: [clientId]);
      state = SessionBundleLoaded(sessionBundle);
    } catch (e) {
      state = SessionsError("Unable to load session");
    }
  }

  Future<void> _initSession(context, int serviceId) async {
    try {
      final result =
          await ClientListAlertDialog(context: context, onConfirm: () {})
              .show();
      if (result != null) {
        await DateTimeModel(meta: 'paused_time').removeDateTime();
        await DateTimeModel(meta: 'current_process_start_Time')
            .removeDateTime(); // this is just incase the date time was not remoed from before;
        final session = await SessionModel().initSession(result, serviceId);
        Navigator.pushNamed(context, "/live-session", arguments: {
          'sessionModel': session,
        });
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        state = SessionsError(
            "Unable to start session. Please check you are connected to the internet.");
        return;
      }
      state = SessionsError("Unable to start session.");
      return;
    }
  }

  Future<void> checkSessionActivity(context, int serviceId) async {
    try {
      final response = await SessionModel().checkSessionActivity();
      if (response.sessionIsActive) {
        AreYouSureAlertDialog(
          dismissible: true,
          context: context,
          message:
              "${response.service?.serviceName} with ${response.client?.clientFirstName} ${response.client?.clientLastName} is currently in progress.",
          leftButtonText: "Start new session",
          rightButtonText: "Resume session",
          onLeftButton: () async {
            Navigator.of(context).pop();
            _initSession(context, serviceId);
          },
          onRightButton: () async {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/live-session",
                arguments: {'sessionModel': response.session});
          },
        ).show();
      } else {
        _initSession(context, serviceId);
      }
    } catch (e) {
      _initSession(context, serviceId);
    }
  }
}
