import 'package:beauty_fyi/models/client_model.dart';
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
  ClientsNotifier(ClientProviderEnums providerEnum, int? clientId,
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
        state = ClientsError("Unable to load clients");
      } catch (e) {}
    }
    return;
  }

  Future<void> getClient(id) async {
    try {
      state = ClientsLoading();
      final client = await ClientModel(id: id).readClient();
      state = ClientLoaded(client);
    } catch (e) {
      state = ClientsError("Unable to load client");
    }
  }
}
