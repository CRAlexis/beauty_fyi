import 'dart:collection';
import 'dart:developer';

import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/models/service_media_model.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InitSessionResponseType {
  bool sessionIsActive;
  SessionModel? session;
  ServiceModel? service;
  ClientModel? client;
  InitSessionResponseType(
      this.sessionIsActive, this.session, this.service, this.client);
}

class SessionModel {
  String? id;
  String? clientId;
  DateTime? dateTime;
  String? notes;
  bool? active;
  int? currentProcess;
  int? serviceId;
  String? serviceName;
  String? url;
  SessionModel(
      {this.id,
      this.clientId,
      this.serviceId,
      this.dateTime,
      this.notes,
      this.active,
      this.currentProcess,
      this.serviceName,
      this.url});

  Map<String, dynamic> get _toMap {
    return {
      'id': id,
      'client_id': clientId,
      'service_id': serviceId,
      'date_time': dateTime.toString(),
      'notes': notes,
      'active': active ?? false ? 1 : 0,
      'current_process': currentProcess,
      'url': url
    };
  }

  SessionModel _toModel(Map<String, dynamic> query) {
    return SessionModel(
        id: query['id'],
        clientId: query['client_id'],
        dateTime: DateTime.parse(query['date_time']),
        notes: query['notes'],
        currentProcess: query['current_process'],
        serviceId: query['service_id'],
        url: query['url']);
  }

  set setSessionId(String sessionId) {
    this.id = sessionId;
  }

  set setCurrentProcess(int currentProcess) {
    this.currentProcess = currentProcess;
  }

  set setNotes(String notes) {
    this.notes = notes;
  }

  set setClientId(String clientId) {
    this.clientId = clientId;
  }

  set setActive(bool active) {
    this.active = active;
  }

  Future<InitSessionResponseType> checkSessionActivity() async {
    try {
      final HttpService http = HttpService();
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));

      Response response =
          await http.getRequest(endPoint: 'sessions/check-activity/1');
      if (!response.data['sessionIsActive']) {
        return InitSessionResponseType(
            response.data['sessionIsActive'], null, null, null);
      }

      final List<Map<String, dynamic>> sessionQuery = await db.query('sessions',
          where: "id = ?", whereArgs: [response.data['sessionId']]);
      final service = await ServiceModel(id: sessionQuery.first['service_id'])
          .readService();
      final client =
          await ClientModel(id: response.data['clientId']).readClient();

      return InitSessionResponseType(response.data['sessionIsActive'],
          _toModel(sessionQuery[0]), service, client);
    } catch (e) {
      throw e;
    }
  }

  Future<SessionModel> initSession(String clientId, int serviceId) async {
    try {
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();
      final Database db = await openDatabase(
          join(await getDatabasesPath(), "beautyfyi_database.db"));
      content['clientId'] = clientId;
      Response response =
          await http.postRequest(endPoint: 'sessions/1', data: content);
      print("response: $response");
      final _ = SessionModel(
          id: response.data['sessionId'],
          clientId: clientId,
          dateTime: DateTime.now(),
          notes: '',
          currentProcess: 0,
          serviceId: serviceId,
          url: response.data['url']);
      await db.insert('sessions', _._toMap);
      return _;
    } catch (error) {
      throw (error);
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
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();
      content['sessionId'] = this.id;
      content['clientId'] = this.clientId;
      print("clientId ${this.clientId}");
      Response response = await http.postRequest(
          endPoint: 'sessions/end-session/1', data: content);
      return;
    } catch (error) {
      throw error;
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
        if (session['id'] == null) {
        } else {
          services
              .add(await ServiceModel(id: session['service_id']).readService());
          serviceMedias.add(await ServiceMedia()
              .readServiceMedia(sql: "session_id = ?", args: [session['id']]));

          sessions.add(SessionModel(
            id: session['id'],
            clientId: session['client_id'],
            serviceId: session['service_id'],
            dateTime: DateTime.parse(session['date_time']),
            notes: session['notes'],
            active: session['active'] == 1,
            currentProcess: session['current_process'],
          ));
        }
      });
      return SessionBundleModel(
          sessionModel: sessions,
          serviceModel: services,
          serviceMedia: serviceMedias);
    } catch (e) {
      print(e);
      throw e;
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
