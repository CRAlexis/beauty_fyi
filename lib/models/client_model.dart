import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ClientModel {
  final int clientId;
  final String clientName;

  ClientModel({this.clientId, this.clientName});

  Map<String, dynamic> get map {
    return {'client_name': clientName};
  }

  Future<bool> insertClient(ClientModel clientModel) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.insert(
        'clients',
        clientModel.map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> updateClient(ClientModel clientModel) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.update('clients', clientModel.map,
          where: "id = ?", whereArgs: [clientId]);
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> deleteClient() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query =
          await db.delete('clients', where: "id = ?", whereArgs: [clientId]);
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<List<ClientModel>> readClients() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query = await db.query('clients');
      return List.generate(query.length, (index) {
        return ClientModel(
            clientId: query[index]['id'],
            clientName: query[index]['client_name']);
      });
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<ClientModel> readClient() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query =
          await db.query('clients', where: "id = ?", whereArgs: [clientId]);
      return ClientModel(
          clientId: query[0]['id'], clientName: query[0]['client_name']);
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }
}
