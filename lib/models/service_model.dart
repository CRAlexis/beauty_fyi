import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ServiceModel {
  final int? id;
  final String? serviceName;
  final String? serviceDescription;
  final File? imageSrc;
  final String? serviceProcesses;

  ServiceModel(
      {this.id,
      this.serviceName,
      this.serviceDescription,
      this.imageSrc,
      this.serviceProcesses});

  Map<String, dynamic> toMap() {
    return {
      "service_name": serviceName!.isNotEmpty ? serviceName?.trim() : "Unnamed",
      "service_description":
          serviceDescription!.isNotEmpty ? serviceDescription?.trim() : "",
      "service_image": imageSrc!.path,
      "service_processes": serviceProcesses,
    };
  }

  Future<bool> insertService(ServiceModel serviceModal) async {
    print("inserting service");

    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      await db.insert(
        'services',
        serviceModal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Created service successfully");
      return true;
    } catch (e) {
      print("failed creating service");
      return Future.error(e, StackTrace.fromString(""));
    }
  }

  Future<List<ServiceModel>> readServices() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final List<Map<String, dynamic>> maps = await db.query('services');
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

  Future<bool> updateService() async {
    print("updating service");
    try {
      Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final int query = await db.update('services', this.toMap(),
          where: "id = ?",
          whereArgs: [this.id],
          conflictAlgorithm: ConflictAlgorithm.rollback);
      return query == 1;
    } catch (e) {
      print(e);
      return Future.error(e, StackTrace.fromString(""));
    }
  }

  Future<bool> deleteService() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final int query =
          await db.delete('services', where: "id = ?", whereArgs: [id]);
      return query == 1;
    } catch (e) {
      return Future.error(e, StackTrace.fromString(""));
    }
  }
}
