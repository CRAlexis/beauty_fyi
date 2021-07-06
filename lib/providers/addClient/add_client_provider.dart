import 'package:beauty_fyi/container/alert_dialoges/loading_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class AddClientState {
  const AddClientState();
}

class AddClientInitial extends AddClientState {
  const AddClientInitial();
}

class AddClientQuerying extends AddClientState {
  const AddClientQuerying();
}

class AddClientSuccess extends AddClientState {
  const AddClientSuccess();
}

class AddClientError extends AddClientState {
  final String message;
  const AddClientError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is AddClientError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class AddClientNotifier<AddClientState> extends StateNotifier {
  AddClientNotifier([AddClientState? state]) : super(AddClientInitial());

  Future<void> sendQuery(ClientModel clientModel, context) async {
    final loadingAlertDialog = LoadingAlertDialog(
        context: context, message: "Adding ${clientModel.clientFirstName}...");
    try {
      loadingAlertDialog.show();
      state = AddClientQuerying;
      print("last: ${clientModel.clientLastName}");
      print("email: ${clientModel.clientEmail}");
      print("number: ${clientModel.clientPhoneNumber}");
      print("here 1");
      await clientModel.insertClient(clientModel);
      print("here 2");

      state = AddClientSuccess;
      loadingAlertDialog.pop();
      MessageAlertDialog(
          message:
              "${clientModel.clientFirstName} ${clientModel.clientLastName} was added as a client.",
          context: context,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          }).show();
      return;
    } catch (e) {
      print(e);
      state = AddClientError("Unable to add client. Please try again");
      loadingAlertDialog.pop();
      throw (e);
    }
  }
}
