import 'dart:convert';
import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/loading_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

abstract class AddServiceState {
  const AddServiceState();
}

class AddServiceInitial extends AddServiceState {
  const AddServiceInitial();
}

class AddServiceLoading extends AddServiceState {
  const AddServiceLoading();
}

class AddServiceLoaded extends AddServiceState {
  const AddServiceLoaded();
}

class AddServiceError extends AddServiceState {
  final String message;
  const AddServiceError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is AddServiceError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class AddServiceNotifier<AddServiceState> extends StateNotifier {
  AddServiceNotifier([AddServiceState? state]) : super(AddServiceInitial());

  List<Color> backgroundColours = [
    colorStyles['dark_purple'] as Color,
    colorStyles['light_purple'] as Color,
    colorStyles['blue'] as Color,
    colorStyles['green'] as Color
  ];
  Map<String, dynamic> recallServiceObject = {
    'serviceId': null,
  };
  Future<Map> recallServiceData(id) async {
    try {
      final Map<dynamic, dynamic> formattedReturnObject = {};
      if (id != null && !(state is AddServiceLoaded)) {
        final service = await _fetchService(id: id);
        final List<ServiceProcess> serviceProcesses = [];
        formattedReturnObject['serviceName'] = service.serviceName as String;
        formattedReturnObject['serviceDescription'] =
            service.serviceDescription as String;
        formattedReturnObject['imageFile'] =
            (service.imageSrc as File).existsSync()
                ? (service.imageSrc as File)
                : new File("");
        List<dynamic> list = json.decode(service.serviceProcesses as String);
        for (var map in list) {
          serviceProcesses.add(ServiceProcess(
              processName: map['processName'],
              processDuration: map['processDuration']));
        }
        formattedReturnObject['serviceProcesses'] = serviceProcesses;
        state = AddServiceLoaded();
        return formattedReturnObject;
      }
      throw "";
    } catch (e) {
      print(e);
      return Future.error("No service found");
    }
  }

  Future<void> sendQuery(
      {required ServiceModel serviceModel,
      required bool updating,
      required BuildContext context}) async {
    final loadingAlertDialog =
        LoadingAlertDialog(context: context, message: "Creating service");
    try {
      String sucessString = "";
      loadingAlertDialog.show();

      switch (updating) {
        case true:
          sucessString = "Updated service successfully";
          await serviceModel.updateService();
          break;
        default:
          sucessString = "Created service successfully";
          await serviceModel.insertService(serviceModel);
          break;
      }

      loadingAlertDialog.pop();

      MessageAlertDialog(
          context: context,
          message: sucessString,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          }).show();
    } catch (e) {
      loadingAlertDialog.pop();
      MessageAlertDialog(
          context: context,
          message: "Error creating service",
          onPressed: () {
            Navigator.of(context).pop();
          }).show();
      print("error: $e");
      throw e;
    }
  }
}

Future<ServiceModel> _fetchService({id}) async {
  final serviceModel = new ServiceModel(id: id);
  return await serviceModel.readService();
}
