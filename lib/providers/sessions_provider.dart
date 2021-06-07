import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:riverpod/riverpod.dart';

enum SessionProviderEnums { READBUNDLE }

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
  SessionsNotifier(SessionProviderEnums providerEnums, int clientId,
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
}
