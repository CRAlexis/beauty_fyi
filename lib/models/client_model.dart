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
        return ClientModel(
            id: query[index]['id'],
            clientFirstName: query[index]['client_first_name'],
            clientLastName: query[index]['client_last_name'],
            clientEmail: query[index]['client_email'],
            clientPhoneNumber: query[index]['client_phone_number'],
            clientImage: query[index]['client_image'] != null
                ? File(query[index]['client_image'])
                : new File(""));
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
      return ClientModel(
          id: query[0]['id'],
          clientFirstName: query[0]['client_first_name'],
          clientLastName: query[0]['client_last_name'],
          clientEmail: query[0]['client_email'],
          clientPhoneNumber: query[0]['client_phone_number'],
          clientImage: File(query[0]['client_image']));
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }
}
