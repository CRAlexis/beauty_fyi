import 'dart:io';

import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ServiceModel {
  final int? id;
  final String? serviceName;
  final String? serviceDescription;
  File? imageSrc;
  final String? serviceProcesses;

  ServiceModel(
      {this.id,
      this.serviceName,
      this.serviceDescription,
      this.imageSrc,
      this.serviceProcesses});

  set imageSet(File? src) {
    this.imageSrc = src;
  }

  Map<String, dynamic> toMap({bool delete = false}) {
    return {
      "service_name": serviceName!.isNotEmpty ? serviceName?.trim() : "Unnamed",
      "service_description":
          serviceDescription!.isNotEmpty ? serviceDescription?.trim() : "",
      "service_image": imageSrc!.path,
      "service_processes": serviceProcesses,
      "deleted": delete ? 1 : 0
    };
  }

  Future<bool> insertService(ServiceModel serviceModal) async {
    print("inserting service");

    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));

      // final _ = await FileAndImageFunctions().getDirectory();
      // serviceModal.imageSrc = await FileAndImageFunctions().moveFile(
      // serviceModal.imageSrc!,
      // "${_.path}/SMPictures/${basename(serviceModal.imageSrc!.path)}");

      await db.insert(
        'services',
        serviceModal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Created service successfully");
      return true;
    } catch (e) {
      print("failed creating service");
      throw e;
    }
  }

  Future<List<ServiceModel>> readServices() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final List<Map<String, dynamic>> maps =
          await db.query('services', where: "deleted = ?", whereArgs: [0]);
      await db.close();

      // print(maps[i]);
      return List.generate(maps.length, (i) {
        return ServiceModel(
          id: maps[i]['id'],
          serviceName: maps[i]['service_name'],
          serviceDescription: maps[i]['service_description'],
          imageSrc: File(maps[i]['service_image']),
          serviceProcesses: maps[i]['service_processes'],
        );
      });
    } catch (e) {
      throw (e);
    }
  }

  Future<ServiceModel> readService() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final List<Map<String, dynamic>> map =
          await db.query('services', where: "id = ?", whereArgs: [id]);
      return ServiceModel(
          id: map.first['id'],
          serviceName: map.first['service_name'],
          serviceDescription: map.first['service_description'],
          serviceProcesses: map.first['service_processes'],
          imageSrc: File(map.first['service_image']));
    } catch (e) {
      throw (e);
    }
  }

  Future<void> updateService() async {
    print("updating service");
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final _ = await FileAndImageFunctions().getDirectory();
      this.imageSet = await FileAndImageFunctions().moveFile(this.imageSrc!,
          "${_.path}/SMPictures/${basename(this.imageSrc!.path)}");
      await db.update('services', this.toMap(),
          where: "id = ?",
          whereArgs: [this.id],
          conflictAlgorithm: ConflictAlgorithm.rollback);
      return;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> deleteService() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      await db.update('services', this.toMap(delete: true),
          where: "id = ?", whereArgs: [id]);
      return;
    } catch (e) {
      throw e;
    }
  }
}
