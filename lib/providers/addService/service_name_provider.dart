import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class ServiceNameState {
  const ServiceNameState();
}

class ServiceNameValidation extends ServiceNameState {
  final bool isValidated;
  const ServiceNameValidation(this.isValidated);
}

class ServiceNameNotifier<ServiceNameState> extends StateNotifier {
  ServiceNameNotifier([ServiceNameState? state])
      : super(ServiceNameValidation(false)) {
    serviceNameTextFieldController.addListener(_serviceNameListener);
    serviceDescriptionTextFieldController
        .addListener(_serviceDescriptionListener);
  }
  final serviceNameForm = GlobalKey<FormState>();
  final FocusNode serviceNameTextFieldFocusNode = new FocusNode();
  final FocusNode serviceDescriptionTextFieldFocusNode = new FocusNode();
  final serviceNameTextFieldController = TextEditingController();
  final serviceDescriptionTextFieldController = TextEditingController();
  AutovalidateMode autovalidateModeServiceName = AutovalidateMode.disabled;
  bool disableTextFields = false;
  final serviceNameRegexString = r'^[a-zA-Z0-9 +&_()\-]+$';
  // final serviceDescriptionRegexString = r'/^[A-Za-z0-9+&-_#@*$£!?^()]+$/';

  void _serviceNameListener() {
    final serviceName = serviceNameTextFieldController.text;
    if (RegExp(serviceNameRegexString).hasMatch(serviceName) &&
        serviceName.length >= 4) {
      state = ServiceNameValidation(true);
    } else {
      state = ServiceNameValidation(false);
    }
  }

  void _serviceDescriptionListener() {
    try {
      final serviceName = serviceNameTextFieldController.text;
      if (RegExp(serviceNameRegexString).hasMatch(serviceName) &&
          serviceName.length >= 4) {
        autovalidateModeServiceName = AutovalidateMode.onUserInteraction;
        state = ServiceNameValidation(true);
      } else {
        autovalidateModeServiceName = AutovalidateMode.onUserInteraction;
        state = ServiceNameValidation(false);
      }
    } catch (error) {
      print(error);
    }
  }

  void softDispose() {
    state = ServiceNameValidation(false);
    serviceNameTextFieldController.text = "";
    serviceDescriptionTextFieldController.text = "";
  }
}
