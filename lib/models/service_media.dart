import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ServiceMedia {
  final int? id;
  final int? sessionId;
  final int? serviceId;
  final int? clientId;
  final String? fileType;
  final String? filePath;
  ServiceMedia(
      {this.id,
      this.sessionId,
      this.serviceId,
      this.clientId,
      this.fileType,
      this.filePath});

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'service_id': serviceId,
      'client_id': clientId,
      'file_type': fileType,
      'file_path': filePath,
    };
  }

  Future<bool> insertServiceMedia(ServiceMedia serviceMedia) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.insert('service_media', serviceMedia.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return query == 1;
    } catch (error) {
      print(error);
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<List<ServiceMedia>> readServiceMedia({sql, args}) async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      List<Map<String, dynamic>> query =
          await db.query('service_media', where: sql, whereArgs: args);
      return List.generate(query.length, (index) {
        return ServiceMedia(
            id: query[index]['id'],
            sessionId: query[index]['session_id'],
            serviceId: query[index]['service_id'],
            clientId: query[index]['client_id'],
            fileType: query[index]['file_type'],
            filePath: query[index]['file_path']);
      });
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> deleteServiceMedia() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.delete('service_media',
          where: "id = ?", whereArgs: [id]); // will need to change this
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }

  Future<bool> deleteServiceMedias() async {
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      int query = await db.delete('service_media',
          where: "service_id = ?",
          whereArgs: [serviceId]); // will need to change this
      return query == 1;
    } catch (error) {
      return Future.error(error, StackTrace.fromString(""));
    }
  }
}
