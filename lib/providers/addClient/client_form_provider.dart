import 'package:beauty_fyi/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

abstract class ClientFormState {
  const ClientFormState();
}

class ClientFormValidation extends ClientFormState {
  final bool isValidated;
  const ClientFormValidation(this.isValidated);
}

class ClientFormNotifier<ClientFormState> extends StateNotifier {
  ClientFormNotifier(ClientModel? clientModel, [ClientFormState? state])
      : super(ClientFormValidation(false)) {
    recallData(clientModel);
    firstNameController.addListener(_validateClientForm);
    // lastNameController.addListener(_validateClientForm);
    // emailAddressController.addListener(_validateClientForm);
    // firstNameFocusNode.addListener(_firstNameFocusChange);
    // lastNameFocusNode.addListener(_lastNameFocusChange);
    // emailAddressFocusNode.addListener(_emailAddressFocusChange);
    // phoneNumberFocusNode.addListener(_phoneNumberFocusChange);
  }
  final GlobalKey<FormState> formKey = GlobalKey();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final FocusNode firstNameFocusNode = new FocusNode();
  final FocusNode lastNameFocusNode = new FocusNode();
  final FocusNode emailAddressFocusNode = new FocusNode();
  final FocusNode phoneNumberFocusNode = new FocusNode();
  AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
  final nameRegexString = r'^[a-zA-Z ]+$';
  String invalidNameString = "Invalid name";
  String invalidLastNameString = "Invalid name";
  String invalidEmailString = "Invalid email address";
  bool validateFirstName = false;
  bool validateLastName = false;
  bool validateEmail = false;
  void _validateClientForm() {
    if (firstNameController.text.trim().length > 1) {
      state = ClientFormValidation(true);
    } else {
      state = ClientFormValidation(false);
    }
  }

  void recallData(ClientModel? clientModel) {
    if (clientModel == null) return;
    firstNameController.text = clientModel.clientFirstName ?? "";
    lastNameController.text = clientModel.clientLastName ?? "";
    emailAddressController.text = clientModel.clientEmail ?? "";
    phoneNumberController.text = clientModel.clientPhoneNumber ?? "";
    state = ClientFormValidation(true);
  }

  // void _firstNameFocusChange() {
  // if (!firstNameFocusNode.hasFocus) {
  // if (firstNameController.text.trim().length > 0) {
  // validateFirstName = true;
  // } else {
  // validateFirstName = false;
  // }
  // }
  // }

  // void _lastNameFocusChange() {
  // if (!lastNameFocusNode.hasFocus) {
  // if (lastNameController.text.trim().length > 0) {
  // validateLastName = true;
  // } else {
  // validateLastName = false;
  // }
  // }
  // }
//
  // void _emailAddressFocusChange() {
  // if (!emailAddressFocusNode.hasFocus) {
  // if (emailAddressController.text.length > 1) {
  // validateEmail = true;
  // } else {
  // validateEmail = false;
  // }
  // }
  // }

  // void _phoneNumberFocusChange() {}
}
