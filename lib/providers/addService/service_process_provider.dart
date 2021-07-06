import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/models/service_process_model.dart';
import 'package:beauty_fyi/providers/services_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class ServiceProcessState {
  const ServiceProcessState();
}

class ServiceProcessInitial extends ServiceProcessState {
  ServiceProcessInitial();
}

class ServiceProcessLoading extends ServiceProcessState {
  const ServiceProcessLoading();
}

class ServiceProcessLoaded extends ServiceProcessState {
  final List<ServiceProcess> serviceProcesses;
  const ServiceProcessLoaded(this.serviceProcesses);
}

class ServiceProcessError extends ServiceProcessState {
  final String message;
  const ServiceProcessError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ServiceProcessError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ServiceProcessNotifier<ServiceProcessState> extends StateNotifier {
  ServiceProcessNotifier([ServiceProcessState? state])
      : super(ServicesInitial());

  List<ServiceProcess> serviceProcesses = [];

  Future<void> displayProcessTextInput({required BuildContext context, index}) {
    String processNameValidationError;
    String processDurationValidationError;
    TextEditingController processNameController = TextEditingController();
    TextEditingController processDurationController = TextEditingController();
    AutovalidateMode processFormAutovalidateMode = AutovalidateMode.disabled;
    final serviceProcessForm = GlobalKey<FormState>();

    processNameValidationError = "Invalid name";
    processDurationValidationError = "Invalid duration";

    if (index != null) {
      processNameController.text = serviceProcesses[index].processName ?? "";
      processDurationController.text =
          serviceProcesses[index].processDuration.toString();
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              scrollable: true,
              title: Text("Service process"),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    child: Form(
                  key: serviceProcessForm,
                  autovalidateMode: processFormAutovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextField(
                        iconData: null,
                        hintText: serviceProcesses.length == 0
                            ? "e.g. Wash clients hair"
                            : "",
                        invalidMessage: processNameValidationError,
                        labelText: "Name",
                        textInputType: TextInputType.text,
                        defaultTextFieldController: processNameController,
                        onSaved: (String? value) {},
                        onChanged: (String value) {},
                        disableTextFields: false,
                        stylingIndex: 2,
                        regex: r'^[a-zA-Z0-9 +&]+$',
                        maxLength: 35,
                        height: 40,
                        labelPadding: 0,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      DefaultTextField(
                          iconData: null,
                          hintText: serviceProcesses.length == 0 ? "10" : "",
                          invalidMessage: processDurationValidationError,
                          labelText: "Duration",
                          textInputType: TextInputType.number,
                          defaultTextFieldController: processDurationController,
                          onSaved: (String? value) {},
                          onChanged: (String value) {
                            setState(() {
                              processFormAutovalidateMode =
                                  AutovalidateMode.onUserInteraction;
                            });
                          },
                          disableTextFields: false,
                          stylingIndex: 2,
                          regex: r'[1-9]',
                          height: 40,
                          labelPadding: 0,
                          suffixText: "(Minutes)",
                          validationStringLength: 1),
                    ],
                  ),
                ));
              }),
              actions: <Widget>[
                index != null
                    ? TextButton(
                        child: Text('REMOVE'),
                        onPressed: () {
                          serviceProcesses.removeAt(index);
                          state = ServiceProcessLoaded(serviceProcesses);
                          Navigator.pop(context);
                        },
                      )
                    : Container(),
                TextButton(
                  child: Text('ADD'),
                  onPressed: () {
                    if (processNameController.text.length == 0 ||
                        processDurationController.text.length == 0) {
                      return;
                    }
                    if (serviceProcessForm.currentState!.validate()) {
                      if (index != null) {
                        serviceProcesses.removeAt(index);
                        serviceProcesses.insert(
                            index,
                            ServiceProcess(
                                processName: processNameController.text,
                                processDuration:
                                    int.parse(processDurationController.text)));
                      } else {
                        serviceProcesses.add(ServiceProcess(
                            processName: processNameController.text,
                            processDuration:
                                int.parse(processDurationController.text)));
                      }

                      state = ServiceProcessLoaded(serviceProcesses);
                      Navigator.pop(context);
                    }
                  },
                ),
              ]);
        });
  }

  Future<void> reorderList(oldIndex, newIndex) async {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    final element = serviceProcesses.removeAt(oldIndex);
    serviceProcesses.insert(newIndex, element);
    state = ServiceProcessLoaded(serviceProcesses);
    return;
  }

  void softDispose() {
    serviceProcesses = [];
    state = ServicesInitial;
  }

  set addServiceProcesses(List<ServiceProcess> processes) {
    serviceProcesses = processes;
    state = ServiceProcessLoaded(serviceProcesses);
  }
}
