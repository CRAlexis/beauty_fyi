import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/create_service/service_image/action_button.dart';
import 'package:beauty_fyi/container/create_service/service_image/gallery_icon_stack.dart';
import 'package:beauty_fyi/container/full_screen_image/bottom_bar.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/providers/addClient/add_client_provider.dart';
import 'package:beauty_fyi/providers/addClient/client_form_provider.dart';
import 'package:beauty_fyi/providers/bottom_bar_provider.dart';
import 'package:beauty_fyi/providers/image_file_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomBarNotfierProvider =
    StateNotifierProvider.autoDispose((ref) => BottomBarNotifier());
final addClientNotifierProvider = StateNotifierProvider.autoDispose
    .family((ref, String? clientId) => AddClientNotifier(clientId));
final clientFormNotifierProvider = StateNotifierProvider.autoDispose
    .family((ref, ClientModel? clientModel) => ClientFormNotifier(clientModel));
final imageFileNotifierProvider =
    StateNotifierProvider.family.autoDispose((ref, String? url) {
  return ImageFileNotifier(url);
});

class AddClientScreen extends ConsumerWidget {
  final args;
  AddClientScreen({this.args});
  final List<Color> backgroundColours = [
    colorStyles['dark_purple'] as Color,
    colorStyles['light_purple'] as Color,
    colorStyles['blue'] as Color,
    colorStyles['green'] as Color
  ];

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final String? clientId = args != null ? args['clientId'] : null;
    final bottomBarNotifierController =
        context.read(bottomBarNotfierProvider.notifier);
    final addClientNotifierController =
        context.read(addClientNotifierProvider(clientId).notifier);

    final state = watch(addClientNotifierProvider(clientId));
    final height = MediaQuery.of(context).size.height - 170;

    return new WillPopScope(
        onWillPop: () {
          if (bottomBarNotifierController.isVisible) {
            bottomBarNotifierController.hideBottomBar();
            return Future.value(false);
          }
          AreYouSureAlertDialog(
              context: context,
              message: "Are  you sure you want to exit?",
              leftButtonText: "no",
              rightButtonText: "yes",
              onLeftButton: () => Navigator.of(context).pop(),
              onRightButton: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }).show();
          return Future.value(false);
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                leftIconClicked: () {
                  if (bottomBarNotifierController.isVisible) {
                    bottomBarNotifierController.hideBottomBar();
                    return;
                  }
                  Navigator.pop(context);
                },
                showMenuIcon: false,
                automaticallyImplyLeading: false),
            body: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  colorStyles['dark_purple']!,
                  colorStyles['light_purple']!,
                  colorStyles['blue']!,
                  colorStyles['green']!
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(children: [
                  ProviderListener(
                      onChange: (context, state) {
                        if (state is AddClientError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              duration: Duration(seconds: 7),
                            ),
                          );
                        }
                      },
                      provider: addClientNotifierProvider(clientId),
                      child: state is AddClientLoaded ||
                              state is AddClientQuerying ||
                              state is AddClientError
                          ? GestureDetector(
                              onTap: () {
                                if (bottomBarNotifierController.isVisible) {
                                  bottomBarNotifierController.hideBottomBar();
                                }
                              },
                              child: AnimatedOpacity(
                                  opacity: bottomBarNotifierController.isVisible
                                      ? 0.2
                                      : 1,
                                  duration: Duration(microseconds: 500),
                                  child: Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.0,
                                            vertical: 80.0,
                                          ),
                                          child: Card(
                                              elevation: 20,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                                  height: height > 400
                                                      ? height
                                                      : 500,
                                                  child: SingleChildScrollView(
                                                    physics:
                                                        AlwaysScrollableScrollPhysics(),
                                                    child: Stack(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            _ClientImage(
                                                                state.client),
                                                            _ClientForm(
                                                                state.client,
                                                                state
                                                                    is AddClientQuerying),
                                                            Consumer(builder:
                                                                (BuildContext
                                                                        context,
                                                                    ScopedReader
                                                                        watch,
                                                                    child) {
                                                              final stateC = watch(
                                                                  clientFormNotifierProvider(
                                                                      state
                                                                          .client));
                                                              return ActionButton(
                                                                  onPressed:
                                                                      () async {
                                                                    addClientNotifierController.sendQuery(
                                                                        ClientModel(
                                                                            id: state
                                                                                .client?.id,
                                                                            clientFirstName:
                                                                                context.read(clientFormNotifierProvider(state.client).notifier).firstNameController.text.trim(),
                                                                            clientLastName: context.read(clientFormNotifierProvider(state.client).notifier).lastNameController.text.trim().length != 0 ? context.read(clientFormNotifierProvider(state.client).notifier).lastNameController.text.trim() : "",
                                                                            clientEmail: context.read(clientFormNotifierProvider(state.client).notifier).emailAddressController.text.trim().length != 0 ? context.read(clientFormNotifierProvider(state.client).notifier).emailAddressController.text.trim() : "",
                                                                            clientPhoneNumber: context.read(clientFormNotifierProvider(state.client).notifier).phoneNumberController.text.trim().length != 0 ? context.read(clientFormNotifierProvider(state.client).notifier).phoneNumberController.text.trim() : "",
                                                                            clientImage: context.read(imageFileNotifierProvider(state.client?.clientImage).notifier).imageFile?.path),
                                                                        context);
                                                                  },
                                                                  iconData:
                                                                      Icons.add,
                                                                  buttonText:
                                                                      "add client",
                                                                  isLoading: stateC
                                                                      is AddClientQuerying,
                                                                  backgroundColor: stateC
                                                                          is ClientFormValidation
                                                                      ? stateC.isValidated
                                                                          ? 'darker_green'
                                                                          : 'green'
                                                                      : 'green');
                                                            })
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )))))))
                          : Center(child: CircularProgressIndicator())),
                  state is AddClientLoaded ||
                          state is AddClientQuerying ||
                          state is AddClientError
                      ? _BottomBar(state.client)
                      : Container()
                ]))));
  }
}

class _ClientImage extends ConsumerWidget {
  final ClientModel? clientModel;

  _ClientImage(this.clientModel);
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final bottomBarNotifierController =
        context.read(bottomBarNotfierProvider.notifier);
    final state = watch(imageFileNotifierProvider(clientModel?.clientImage));
    return Column(
        key: ValueKey<int>(0),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GalleryIconStack(
            size: GalleryIconSize.Medium,
            imageSrc: state is ImageFileLoaded ? state.file : null,
            onPreviewImage: () async {
              if (bottomBarNotifierController.isVisible) {
                bottomBarNotifierController.hideBottomBar();
                return;
              }
              final returnedValue = await Navigator.pushNamed(
                  context, "/full-screen-image", arguments: {
                'imageSrc': state is ImageFileLoaded ? state.file : null
              });
              File? returnedImage =
                  (returnedValue as Map<String, dynamic>)['imageSrc'];
              bool imageHasUpdated = returnedValue['imageHasUpdated'];
              imageHasUpdated
                  ? context
                      .read(imageFileNotifierProvider(clientModel?.clientImage)
                          .notifier)
                      .clearImageFile(context)
                  : context
                      .read(imageFileNotifierProvider(clientModel?.clientImage)
                          .notifier)
                      .setImageFile(returnedImage, null);
              //will need to validate slide
            },
            onOpenGalleryOrCamera: () {
              if (bottomBarNotifierController.isVisible) {
                bottomBarNotifierController.hideBottomBar();
                return;
              } else {
                bottomBarNotifierController.showBottomBar();
              }
            },
          ),
        ]);
  }
}

class _ClientForm extends ConsumerWidget {
  final ClientModel? clientModel;
  final bool disableFields;
  _ClientForm(this.clientModel, this.disableFields);
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(clientFormNotifierProvider(clientModel));
    final clientFormNotifierController =
        context.read(clientFormNotifierProvider(clientModel).notifier);

    return Form(
        key: clientFormNotifierController.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            DefaultTextField(
              iconData: Icons.person,
              hintText: "",
              invalidMessage: clientFormNotifierController.invalidNameString,
              labelText: "First name",
              validationStringLength: 1,
              textInputType: TextInputType.name,
              stylingIndex: 1,
              regex: r'^[a-zA-Z ]+$',
              disableTextFields: disableFields,
              height: 40,
              defaultTextFieldController:
                  clientFormNotifierController.firstNameController,
              validate: clientFormNotifierController.validateFirstName,
              focusNode: clientFormNotifierController.firstNameFocusNode,
            ),
            SizedBox(
              height: 5,
            ),
            DefaultTextField(
              iconData: Icons.person,
              hintText: "",
              invalidMessage:
                  clientFormNotifierController.invalidLastNameString,
              labelText: "Last name",
              validationStringLength: 0,
              textInputType: TextInputType.name,
              stylingIndex: 1,
              regex: r'^[a-zA-Z ]+$',
              disableTextFields: disableFields,
              height: 40,
              defaultTextFieldController:
                  clientFormNotifierController.lastNameController,
              validate: clientFormNotifierController.validateLastName,
              focusNode: clientFormNotifierController.lastNameFocusNode,
            ),
            SizedBox(
              height: 5,
            ),
            DefaultTextField(
              iconData: Icons.email_outlined,
              hintText: "",
              invalidMessage: clientFormNotifierController.invalidEmailString,
              labelText: "Email",
              validationStringLength: 0,
              textInputType: TextInputType.emailAddress,
              stylingIndex: 1,
              regex:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              disableTextFields: disableFields,
              height: 40,
              defaultTextFieldController:
                  clientFormNotifierController.emailAddressController,
              validate: clientFormNotifierController.validateEmail,
              focusNode: clientFormNotifierController.emailAddressFocusNode,
            ),
            SizedBox(
              height: 5,
            ),
            DefaultTextField(
              iconData: Icons.phone,
              hintText: "",
              invalidMessage: "Invalid phone number",
              labelText: "Phone number",
              validationStringLength: 0,
              textInputType: TextInputType.phone,
              stylingIndex: 1,
              regex: r"",
              disableTextFields: disableFields,
              height: 40,
              defaultTextFieldController:
                  clientFormNotifierController.phoneNumberController,
              focusNode: clientFormNotifierController.phoneNumberFocusNode,
            ),
          ],
        ));
  }
}

class _BottomBar extends StatefulWidget {
  final ClientModel? clientModel;
  _BottomBar(this.clientModel);
  @override
  __BottomBarState createState() => __BottomBarState();
}

class __BottomBarState extends State<_BottomBar> with TickerProviderStateMixin {
  late AnimationController bottomBarAnimationController;

  void initState() {
    super.initState();
    bottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    bottomBarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final state = watch(bottomBarNotfierProvider);

        return BottomBar(
            visble: state is BottomBarVisibility ? state.isVisible : false,
            controller: bottomBarAnimationController,
            deleteImage: () => context
                .read(imageFileNotifierProvider(widget.clientModel?.clientImage)
                    .notifier)
                .clearImageFile(context),
            // bottomBarVisible = false;
            // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            openCamera: () async {
              context
                  .read(
                      imageFileNotifierProvider(widget.clientModel?.clientImage)
                          .notifier)
                  .setImageFile(
                      await FileAndImageFunctions.openNativeCamera(), null);
              context.read(bottomBarNotfierProvider.notifier).hideBottomBar();
              // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            },
            openGallery: () async {
              context
                  .read(
                      imageFileNotifierProvider(widget.clientModel?.clientImage)
                          .notifier)
                  .setImageFile(
                      await FileAndImageFunctions.openImagePicker(), null);
              context.read(bottomBarNotfierProvider.notifier).hideBottomBar();
              // bottomBarVisible = false;
              // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            });
      },
    );
  }
}
