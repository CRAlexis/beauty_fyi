import 'package:riverpod/riverpod.dart';

abstract class AddServiceState {
  const AddServiceState();
}

class AddServiceInitial extends AddServiceState {
  const AddServiceInitial();
}

class AddServiceLoading extends AddServiceState {
  const AddServiceLoading();
}

class AddServiceLoaded extends AddServiceState {
  const AddServiceLoaded();
}

class AddServiceError extends AddServiceState {
  final String message;
  const AddServiceError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is AddServiceError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class AddServiceNotifier<AddServiceState> extends StateNotifier {
  AddServiceNotifier([AddServiceState? state]) : super(AddServiceInitial());
}
