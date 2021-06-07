import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:beauty_fyi/extensions/string_extension.dart';

class ClientModel {
  final int? id;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientEmail;
  final String? clientPhoneNumber;
  final File? clientImage;

  ClientModel(
      {this.id,
      this.clientFirstName,
      this.clientLastName,
      this.clientEmail,
      this.clientPhoneNumber,
      this.clientImage});

  Map<String, dynamic> get map {
    return {
      'client_first_name': clientFirstName!.trim().capitalize(),
      'client_last_name': clientLastName!.trim().capitalize(),
      'client_email': clientEmail!.trim(),
      'client_phone_number': clientPhoneNumber!.trim(),
      'client_image': clientImage != null ? clientImage!.path : null
    };
  }

  ClientModel _toModel(Map<String, dynamic> query) {
    return ClientModel(
        id: query['id'],
        clientFirstName: query['client_first_name'] ?? "",
        clientLastName: query['client_last_name'] ?? "",
        clientEmail: query['client_email'] ?? "",
        clientPhoneNumber: query['client_phone_number'] ?? "",
        clientImage: File(query['client_image'] ?? ""));
  }

  Future<bool> insertClient(ClientModel clientModel) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      await db.insert(
        'clients',
        clientModel.map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (error) {
      print(error);
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> updateClient(ClientModel clientModel) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db
          .update('clients', clientModel.map, where: "id = ?", whereArgs: [id]);
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> deleteClient() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.delete('clients', where: "id = ?", whereArgs: [id]);
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
        return _toModel(query[index]);
      });
    } catch (error) {
      print("error $error");
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<ClientModel> readClient() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query =
          await db.query('clients', where: "id = ?", whereArgs: [id]);
      return _toModel(query[0]);
    } catch (error) {
      throw (error);
    }
  }
}
