import 'dart:collection';

import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SessionModel {
  int? id;
  int? clientId;
  DateTime? dateTime;
  String? notes;
  bool? active;
  int? currentProcess;
  int? serviceId;
  String? serviceName;
  SessionModel({
    this.id,
    this.clientId,
    this.serviceId,
    this.dateTime,
    this.notes,
    this.active,
    this.currentProcess,
    this.serviceName,
  });

  Map<String, dynamic> get _toMap {
    return {
      'client_id': clientId,
      'service_id': serviceId,
      'date_time': dateTime.toString(),
      'notes': notes,
      'active': active ?? false ? 1 : 0,
      'current_process': currentProcess,
    };
  }

  SessionModel _toModel(Map<String, dynamic> query) {
    return SessionModel(
        id: query['id'],
        clientId: int.parse(query['client_id']),
        dateTime: DateTime.parse(query['date_time']),
        notes: query['notes'],
        active: query['active'] == 1,
        currentProcess: query['current_process'],
        serviceId: query['service_id']);
  }

  set setSessionId(int sessionId) {
    this.id = sessionId;
  }

  set setCurrentProcess(int currentProcess) {
    this.currentProcess = currentProcess;
  }

  set setNotes(String notes) {
    this.notes = notes;
  }

  set setClientId(int clientId) {
    this.clientId = clientId;
  }

  set setActive(bool active) {
    this.active = active;
  }

  Future<int> checkSessionActivity() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      final List<Map<String, dynamic>> query = await db.query("sessions");
      int sessionIsActive = 0;
      query.every((element) {
        if (element['active'] == 1) {
          sessionIsActive = element['service_id'];
          return false;
        }
        return true;
      });
      return sessionIsActive;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> sessionInit() async {
    try {
      bool sessionIsActive = false;
      String? clientName;
      String? serviceName;
      SessionModel? previousSession;
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      final List<Map<String, dynamic>> query = await db.query("sessions");

      if (query.isEmpty) {
        return {
          'activeSession': false,
          'clientName': null,
          'serviceName': null,
          'previousSession': null
        };
      }

      query.every((element) {
        if (element['active'] == 1) {
          sessionIsActive = true;
          previousSession = SessionModel(
              id: element['id'],
              clientId: int.parse(element['client_id']),
              dateTime: DateTime.parse(element['date_time']),
              notes: element['notes'],
              active: element['active'] == 1,
              currentProcess: element['current_process'],
              serviceId: element['service_id']);
          return false;
        }
        return true;
      });

      if (sessionIsActive) {
        List<Map<String, dynamic>> clientQuery = await db.query('clients',
            where: "id = ?", whereArgs: [previousSession!.clientId]);
        clientName =
            "${clientQuery.first['client_first_name']} ${clientQuery.first['client_last_name']}";
        List<Map<String, dynamic>> serviceQuery = await db.query('services',
            where: "id = ?", whereArgs: [previousSession!.serviceId]);
        serviceName = serviceQuery.first['service_name'];
      }
      return {
        'activeSession': sessionIsActive,
        'clientName': clientName,
        'serviceName': serviceName,
        'previousSession': previousSession
      };
    } catch (error) {
      throw (error);
    }
  }

  Future<SessionModel> startSession() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));

      final List<Map<String, dynamic>> sessions = await db.query("sessions");
      if (sessions.isNotEmpty) {
        sessions.every((element) {
          if (element['active'] == 1) {
            try {
              db.update(
                  'sessions',
                  SessionModel(
                          id: element['id'],
                          clientId: int.parse(element['client_id']),
                          serviceId: element['service_id'],
                          dateTime: DateTime.parse(element['date_time']),
                          notes: element['notes'],
                          active: false,
                          currentProcess: 0)
                      ._toMap,
                  where: "id = ?",
                  whereArgs: [element['id']]);
            } catch (e) {
              db.update(
                  'sessions',
                  SessionModel(
                          id: element['id'],
                          clientId: 0,
                          serviceId: element['service_id'],
                          dateTime: DateTime.now(),
                          notes: "",
                          active: false,
                          currentProcess: 0)
                      ._toMap,
                  where: "id = ?",
                  whereArgs: [element['id']]);
            }
          }
          return true;
        });
      }
      await db.insert('sessions', this._toMap);
      this.id = sessions.length + 1;
      return this;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateSession() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      await db.update('sessions', this._toMap,
          where: "id = ?", whereArgs: [this.id]);
      return;
    } catch (e) {
      throw (e);
    }
  }

  Future<void> updateSessionNotes() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      await db.rawUpdate('UPDATE sessions SET notes = ? WHERE id = ${this.id}',
          ["${this.notes}"]);
      return;
    } catch (e) {
      throw (e);
    }
  }

  Future<void> endSession() async {
    try {
      this.active = false;
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      await db.update('sessions', this._toMap,
          where: "id = ?", whereArgs: [this.id]);
      return;
    } catch (e) {
      return Future.error(e, StackTrace.current);
    }
  }

  Future<SessionBundleModel> readSessions({required sql, required args}) async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      List<Map<String, dynamic>> query =
          await db.query('sessions', where: sql, whereArgs: args);
      List<SessionModel> sessions = [];
      List<ServiceModel> services = [];
      List<List<ServiceMedia>> serviceMedias = [];
      await Future.forEach(query, (Map<String, dynamic> session) async {
        services
            .add(await ServiceModel(id: session['service_id']).readService());
        serviceMedias.add(await ServiceMedia()
            .readServiceMedia(sql: "session_id = ?", args: [session['id']]));

        sessions.add(SessionModel(
          id: session['id'],
          clientId: int.parse(session['client_id']),
          serviceId: session['service_id'],
          dateTime: DateTime.parse(session['date_time']),
          notes: session['notes'],
          active: session['active'] == 1,
          currentProcess: session['current_process'],
        ));
      });
      return SessionBundleModel(
          sessionModel: sessions,
          serviceModel: services,
          serviceMedia: serviceMedias);
    } catch (e) {
      print(e);
      return Future.error(e, StackTrace.current);
    }
  }

  Future<ServiceMetaData> fetchServiceMetaData() async {
    try {
      final Database db = await openDatabase(
          join(await getDatabasesPath(), 'beautyfyi_database.db'));
      final List<Map<String, dynamic>> query =
          await db.query('sessions', where: 'active = ?', whereArgs: [0]);
      final Map<int, List<SessionModel>> sessionsSortedById = {};
      final Map<int, int> sessionPopularity = {};

      await Future.forEach(query, (Map<String, dynamic> session) async {
        try {
          final s = _toModel(session);
          sessionsSortedById[s.serviceId] == null
              ? () {
                  sessionsSortedById[s.serviceId as int] = [];
                  sessionPopularity[s.serviceId as int] = 0;
                }()
              : null;
          sessionPopularity[s.serviceId as int] =
              sessionPopularity[s.serviceId as int]! + 1;
          sessionsSortedById[s.serviceId]?.add(s);
        } catch (e) {
          print("top catch: $e");
        }
      });

      final sortedByPopularity = new SplayTreeMap<int, int>.from(
          sessionPopularity,
          (a, b) => sessionPopularity[a]! < sessionPopularity[b]! ? 1 : -1);
      int i = 1;
      int? popIndex;
      sortedByPopularity.forEach((key, value) {
        if (key == this.serviceId) {
          popIndex = i;
        }
        i++;
      });
      return ServiceMetaData(
          sessionsSortedById[this.serviceId] != null
              ? sessionsSortedById[this.serviceId]!.length
              : 0,
          87,
          popIndex ?? 0);
    } catch (e) {
      print("bottom catch: $e");
      return ServiceMetaData(null, null, null);
    }
  }
}
