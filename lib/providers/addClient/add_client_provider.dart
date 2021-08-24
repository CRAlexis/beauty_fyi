import 'package:beauty_fyi/container/alert_dialoges/loading_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path/path.dart';

abstract class AddClientState {
  const AddClientState();
}

class AddClientInitial extends AddClientState {
  const AddClientInitial();
}

class AddClientLoaded extends AddClientState {
  final ClientModel? client;
  const AddClientLoaded(this.client);
}

class AddClientQuerying extends AddClientState {
  final ClientModel? client;
  const AddClientQuerying(this.client);
}

class AddClientSuccess extends AddClientState {
  const AddClientSuccess();
}

class AddClientError extends AddClientState {
  final ClientModel? client;
  final String message;
  const AddClientError(this.message, this.client);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is AddClientError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class AddClientNotifier<AddClientState> extends StateNotifier {
  AddClientNotifier(String? clientId, [AddClientState? state])
      : super(AddClientInitial()) {
    init(clientId);
  }

  Future<void> init(String? clientId) async {
    if (clientId != null) {
      final client = await ClientModel(id: clientId).readClient();
      state = AddClientLoaded(client);

      return;
    }
    state = AddClientLoaded(null);
  }

  Future<void> sendQuery(ClientModel clientModel, context) async {
    final loadingAlertDialog = LoadingAlertDialog(
        context: context, message: "Adding ${clientModel.clientFirstName}...");
    try {
      loadingAlertDialog.show();
      late String successMessage;
      state = AddClientQuerying(clientModel);

      switch (clientModel.id) {
        case null:
          print("inserting client");
          await clientModel.insertClient(clientModel);
          successMessage = "has been added as a client.";
          break;
        default:
          print("updating client");
          await clientModel.updateClient(clientModel);
          successMessage = "has been updated.";
          break;
      }

      state = AddClientSuccess;
      loadingAlertDialog.pop();
      Navigator.pop(context, 'refresh');
      // final messageAlertDialog = MessageAlertDialog(
      //     message:
      //         "${clientModel.clientFirstName} ${clientModel.clientLastName} $successMessage",
      //     context: context,
      //     onPressed: () {
      //       Navigator.pop(context, 'refresh');
      //       // Navigator.pop(context, 'refresh');
      //     });
      // messageAlertDialog.show();
    } catch (e) {
      print(e);
      state =
          AddClientError("Unable to add client. Please try again", clientModel);
      loadingAlertDialog.pop();
    }
  }
}
