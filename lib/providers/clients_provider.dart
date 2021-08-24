import 'dart:convert';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod/riverpod.dart';

enum ClientProviderEnums { READALL, READONE, NULL }

abstract class ClientsState {
  const ClientsState();
}

class ClientsInitial extends ClientsState {
  const ClientsInitial();
}

class ClientsLoading extends ClientsState {
  const ClientsLoading();
}

class ClientLoaded extends ClientsState {
  final ClientModel client;
  const ClientLoaded(this.client);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ClientLoaded && o.client == client;
  }

  @override
  int get hashCode => client.hashCode;
}

class ClientsLoaded extends ClientsState {
  final List<ClientModel> clients;
  const ClientsLoaded(this.clients);
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ClientsLoaded && o.clients == clients;
  }

  @override
  int get hashCode => clients.hashCode;
}

class ClientsError extends ClientsState {
  final String message;
  const ClientsError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ClientsError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier(ClientProviderEnums providerEnum, String? clientId,
      [ClientsState? state])
      : super(ClientsInitial()) {
    switch (providerEnum) {
      case ClientProviderEnums.READALL:
        getClients();
        break;
      case ClientProviderEnums.READONE:
        getClient(clientId);
        break;
      default:
        getClients();
        break;
    }
  }

  Future<void> getClients() async {
    try {
      state = ClientsLoading();
      final clients = await ClientModel().readClients();
      clients.sort((a, b) => ("${a.clientFirstName!} ${a.clientLastName!}")
          .toLowerCase()
          .compareTo(
              ("${b.clientFirstName!} ${b.clientLastName!}").toLowerCase()));
      state = ClientsLoaded(clients);
    } catch (e) {
      try {
        print(e);
        state = ClientsError("Unable to load clients");
      } catch (e) {}
    }
    return;
  }

  Future<void> getClient(id) async {
    try {
      state = ClientsLoading();
      state = ClientLoaded(await ClientModel(id: id).readClient());
    } catch (e) {
      print(e);
      state = ClientsError("Unable to load client");
    }
  }

  Future<void> deleteClient(id, BuildContext context) async {
    try {
      final _ = AreYouSureAlertDialog(
          context: context,
          message: "Are you sure you want to delete this client?",
          leftButtonText: 'no',
          rightButtonText: 'yes',
          onLeftButton: () => Navigator.of(context).pop(),
          onRightButton: () async {
            await ClientModel(id: id).deleteClient();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
      _.show();
    } catch (e) {
      Navigator.of(context).pop();
      state = ClientsError("Unable to delete client");
    }
  }
}
