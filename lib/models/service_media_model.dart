import 'dart:io';

import 'package:beauty_fyi/functions/random_string.dart';
import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/providers/camera_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ServiceMedia {
  final String? id;
  final String? sessionId;
  final int? serviceId;
  final String? clientId;
  final String? fileType;
  final String? filePath;
  final bool? onServer;
  ServiceMedia(
      {this.id,
      this.sessionId,
      this.serviceId,
      this.clientId,
      this.fileType,
      this.filePath,
      this.onServer});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'service_id': serviceId,
      'client_id': clientId,
      'file_type': fileType,
      'file_path': filePath,
      'on_server': onServer == true ? 1 : 0
    };
  }

  set id(String? id) {
    this.id = id;
  }

  set onServer(bool? bool) {
    this.onServer = onServer;
  }

  Future<void> insertServiceMedia(CameraEnum cameraEnum) async {
    Database db = await openDatabase(
        join(await getDatabasesPath(), 'beautyfyi_database.db'));
    late String response;
    late bool onServer;
    try {
      if (cameraEnum == CameraEnum.LIVESESSION) {
        response = await _uploadToServer();
        onServer = true;
      } else {
        response = RandomString().getRandomString(10);
        onServer = false;
      }

      print("response: $response");
      await db.insert(
          'service_media',
          ServiceMedia(
                  id: response,
                  sessionId: this.sessionId,
                  serviceId: this.serviceId,
                  fileType: this.fileType,
                  filePath: this.filePath,
                  clientId: this.clientId,
                  onServer: onServer)
              .toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("# 6");

      return;
    } catch (error) {
      print("# error 2: $error");
      try {
        this.id = RandomString().getRandomString(10);
        this.onServer = false;
        await db.insert('service_media', this.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        print(e);
        throw e;
      }
    }
  }

  Future<String> _uploadToServer() async {
    try {
      final HttpService http = HttpService();

      FormData content = FormData.fromMap({
        'sessionId': this.sessionId,
        'clientId': this.clientId,
        'fileType': this.fileType
      });
      content.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(this.filePath as String,
              filename: 'SMImage.${basename(filePath!)}')));

      Response response =
          await http.postRequest(endPoint: 'sessions/media/1', data: content);

      return response.data['serviceMediaId'];
    } catch (e) {
      print("#error 3: $e");
      throw e;
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
      throw error;
    }
  }

  Future<void> deleteServiceMedia() async {
    try {
      print("deleting service media");
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();
      content['id'] = this.id;
      await db.delete('service_media', where: "id = ?", whereArgs: [id]);
      try {
        await http.deleteRequest(endPoint: 'sessions/media/1', data: content);
      } catch (e) {
        print(e);
        if (e is DioError) {}
      }
      return;
    } catch (error) {
      throw error;
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
      throw error;
    }
  }
}
