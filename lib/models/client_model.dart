import 'dart:convert';
import 'dart:io';

import 'package:beauty_fyi/http/http_service.dart';
import 'package:beauty_fyi/models/global.model.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:beauty_fyi/extensions/string_extension.dart';

class ClientModel {
  final String? id;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientEmail;
  final String? clientPhoneNumber;
  final String? clientImage;

  ClientModel(
      {this.id,
      this.clientFirstName,
      this.clientLastName,
      this.clientEmail,
      this.clientPhoneNumber,
      this.clientImage});

  Map<String, dynamic> get map {
    return {
      'id': id,
      'client_first_name': clientFirstName!.trim().capitalize(),
      'client_last_name': clientLastName!.length != 0
          ? clientLastName!.trim().capitalize()
          : clientLastName,
      'client_email': clientEmail!.trim(),
      'client_phone_number': clientPhoneNumber!.trim(),
      'client_image': clientImage != null ? clientImage! : null
    };
  }

  ClientModel _toModelFromCloud(Map<String, dynamic> data) {
    try {
      ClientModel client = ClientModel(
          id: data['_id'],
          clientFirstName: data['firstName'] ?? "",
          clientLastName: data['lastName'] ?? "",
          clientEmail: data['email'] ?? "",
          clientPhoneNumber: data['phoneNumber'] ?? "",
          clientImage: data['image'] != 'null'
              ? GlobalVariables.serverUrl + 'clients/media/' + data['image']
              : null);
      return client;
    } catch (e) {
      throw (e);
    }
  }

  List<ClientModel> toListModelFromCloud(List<dynamic> data) {
    try {
      List<ClientModel> clients = [];
      data.forEach((element) {
        clients.add(ClientModel(
            id: element['id'],
            clientFirstName: element['firstName'] ?? "",
            clientLastName: element['lastName'] ?? "",
            clientEmail: element['email'] ?? "",
            clientPhoneNumber: element['phoneNumber'] ?? "",
            clientImage: GlobalVariables.serverUrl +
                'clients/media/' +
                element['image']));
      });
      return clients;
    } catch (e) {
      throw (e);
    }
  }

  Future<void> insertClient(ClientModel clientModel) async {
    try {
      final HttpService http = HttpService();
      FormData content = FormData.fromMap({
        'firstName': clientModel.clientFirstName,
        'lastName': clientModel.clientLastName,
        'email': clientModel.clientEmail,
        'phoneNumber': clientModel.clientPhoneNumber,
      });
      if (clientModel.clientImage != null) {
        content.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(clientModel.clientImage!,
                filename: 'CImage.${basename(clientModel.clientImage!)}')));
      }
      await http.postRequest(endPoint: 'clients', data: content);
      return;
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateClient(ClientModel clientModel) async {
    try {
      final HttpService http = HttpService();
      FormData content = FormData.fromMap({
        'id': clientModel.id,
        'firstName': clientModel.clientFirstName,
        'lastName': clientModel.clientLastName,
        'email': clientModel.clientEmail,
        'phoneNumber': clientModel.clientPhoneNumber,
      });
      if (clientModel.clientImage != null) {
        content.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(clientModel.clientImage!,
                filename: 'CImage.${basename(clientModel.clientImage!)}')));
      }
      await http.putRequest(endPoint: 'clients', data: content);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> deleteClient() async {
    try {
      final HttpService http = HttpService();
      final content = new Map<String, dynamic>();

      content['clientId'] = id;
      print("id: $id");
      await http.deleteRequest(endPoint: 'clients', data: content);
    } catch (error) {
      throw (error);
    }
  }

  Future<List<ClientModel>> readClients() async {
    try {
      final HttpService http = HttpService();
      Response response = await http.getRequest(endPoint: 'clients');
      final List<ClientModel> clients =
          ClientModel().toListModelFromCloud((response.data as List<dynamic>));
      return clients;
    } catch (error) {
      print("error $error");
      throw (error);
    }
  }

  Future<ClientModel> readClient() async {
    try {
      final HttpService http = HttpService();
      Response response = await http.getRequest(endPoint: "clients/${this.id}");
      return ClientModel()._toModelFromCloud((response.data));
    } catch (error) {
      throw (error);
    }
  }
}
