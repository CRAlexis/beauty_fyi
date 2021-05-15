import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/create_service/service_image/action_button.dart';
import 'package:beauty_fyi/container/create_service/service_image/gallery_icon_stack.dart';
import 'package:beauty_fyi/container/full_screen_image/bottom_bar.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/client_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class AddClientScreen extends StatefulWidget {
  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen>
    with TickerProviderStateMixin {
  AnimationController bottomBarAnimationController;
  final GlobalKey<FormState> formKey = GlobalKey();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  List<Color> backgroundColours = [
    colorStyles['dark_purple'],
    colorStyles['light_purple'],
    colorStyles['blue'],
    colorStyles['green']
  ];
  File imageSrc;
  String firstName = "";
  String lastName = "";
  String emailAddress = "";
  String phoneNumber = "";
  bool bottomBarVisible = false;
  bool disableTextFields = false;

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
    final height = MediaQuery.of(context).size.height - 170;
    return new WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                rightIcon: null,
                leftIconClicked: () {
                  Navigator.pop(context);
                },
                rightIconClicked: () {},
                automaticallyImplyLeading: false),
            body: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: true
                        ? LinearGradient(
                            colors: [
                                colorStyles['dark_purple'],
                                colorStyles['light_purple'],
                                colorStyles['blue'],
                                colorStyles['green']
                              ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                        : LinearGradient(
                            colors: [
                                backgroundColours[2],
                                backgroundColours[1],
                                backgroundColours[3],
                                backgroundColours[0]
                              ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                child: Stack(children: [
                  GestureDetector(
                      onTap: () {
                        if (bottomBarVisible) {
                          setState(() {
                            bottomBarVisible = !bottomBarVisible;
                          });
                        }
                      },
                      child: AnimatedOpacity(
                          opacity: bottomBarVisible ? 0.2 : 1,
                          /* if something pops up on the screen */
                          duration: Duration(microseconds: 500),
                          child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 80.0,
                                  ),
                                  child: Card(
                                      elevation: 20,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          height: height > 400 ? height : 500,
                                          child: Form(
                                              key: formKey,
                                              autovalidateMode:
                                                  autovalidateMode,
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        GalleryIconStack(
                                                          size: GalleryIconSize
                                                              .Medium,
                                                          imageSrc: imageSrc,
                                                          onPreviewImage: () {
                                                            if (bottomBarVisible) {
                                                              setState(() {
                                                                bottomBarVisible =
                                                                    !bottomBarVisible;
                                                              });
                                                              return;
                                                            }
                                                            Navigator.pushNamed(
                                                                context,
                                                                "/full-screen-image",
                                                                arguments: {
                                                                  'imageSrc':
                                                                      imageSrc
                                                                }).then(
                                                                (value) {
                                                              File
                                                                  returnedImage =
                                                                  (value as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                      'imageSrc'];
                                                              bool override =
                                                                  (value as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                      'override'];
                                                              setState(() {
                                                                if (returnedImage !=
                                                                    null) {
                                                                  imageSrc =
                                                                      returnedImage;
                                                                } else {
                                                                  if (override) {
                                                                    imageSrc =
                                                                        null;
                                                                  }
                                                                }
                                                              });
                                                            });
                                                          },
                                                          onOpenGalleryOrCamera:
                                                              () {
                                                            if (bottomBarVisible) {
                                                              setState(() {
                                                                bottomBarVisible =
                                                                    !bottomBarVisible;
                                                              });
                                                              return;
                                                            }
                                                            setState(() {
                                                              bottomBarVisible =
                                                                  !bottomBarVisible;
                                                            });
                                                            //open camera
                                                          },
                                                        ),
                                                        DefaultTextField(
                                                          iconData:
                                                              Icons.person,
                                                          hintText: "",
                                                          invalidMessage:
                                                              "Invalid name",
                                                          labelText:
                                                              "First name",
                                                          validationStringLength:
                                                              3,
                                                          textInputType:
                                                              TextInputType
                                                                  .name,
                                                          onSaved:
                                                              (String value) {},
                                                          onChanged:
                                                              (String value) {
                                                            firstName = value;
                                                          },
                                                          stylingIndex: 1,
                                                          regex:
                                                              r'^[a-zA-Z ]+$',
                                                          disableTextFields:
                                                              disableTextFields,
                                                          height: 40,
                                                          defaultTextFieldController:
                                                              firstNameController,
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        DefaultTextField(
                                                          iconData:
                                                              Icons.person,
                                                          hintText: "",
                                                          invalidMessage:
                                                              "Invalid name",
                                                          labelText:
                                                              "Last name",
                                                          validationStringLength:
                                                              0,
                                                          textInputType:
                                                              TextInputType
                                                                  .name,
                                                          onSaved:
                                                              (String value) {},
                                                          onChanged:
                                                              (String value) {
                                                            lastName = value;
                                                          },
                                                          stylingIndex: 1,
                                                          regex:
                                                              r'^[a-zA-Z ]+$',
                                                          disableTextFields:
                                                              disableTextFields,
                                                          height: 40,
                                                          defaultTextFieldController:
                                                              lastNameController,
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        DefaultTextField(
                                                          iconData: Icons
                                                              .email_outlined,
                                                          hintText: "",
                                                          invalidMessage:
                                                              "Invalid email",
                                                          labelText: "Email",
                                                          validationStringLength:
                                                              0,
                                                          textInputType:
                                                              TextInputType
                                                                  .emailAddress,
                                                          onSaved:
                                                              (String value) {},
                                                          onChanged:
                                                              (String value) {
                                                            emailAddress =
                                                                value;
                                                          },
                                                          stylingIndex: 1,
                                                          regex:
                                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                                          disableTextFields:
                                                              disableTextFields,
                                                          height: 40,
                                                          defaultTextFieldController:
                                                              emailAddressController,
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        DefaultTextField(
                                                          iconData: Icons.phone,
                                                          hintText: "",
                                                          invalidMessage:
                                                              "Invalid phone number",
                                                          labelText:
                                                              "Phone number",
                                                          validationStringLength:
                                                              0,
                                                          textInputType:
                                                              TextInputType
                                                                  .phone,
                                                          onSaved:
                                                              (String value) {},
                                                          onChanged:
                                                              (String value) {
                                                            phoneNumber = value;
                                                          },
                                                          stylingIndex: 1,
                                                          regex: r"",
                                                          disableTextFields:
                                                              disableTextFields,
                                                          height: 40,
                                                          defaultTextFieldController:
                                                              phoneNumberController,
                                                        ),
                                                        ActionButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                autovalidateMode =
                                                                    AutovalidateMode
                                                                        .onUserInteraction;
                                                                disableTextFields =
                                                                    true;
                                                              });
                                                              try {
                                                                final bool success = await addClient(
                                                                    firstName:
                                                                        firstName,
                                                                    lastName:
                                                                        lastName,
                                                                    email:
                                                                        emailAddress,
                                                                    phoneNumber:
                                                                        phoneNumber,
                                                                    clientImage:
                                                                        imageSrc,
                                                                    formKey:
                                                                        formKey);
                                                                if (success) {
                                                                  MessageAlertDialog(
                                                                      message:
                                                                          "$firstName $lastName was added as a client.",
                                                                      context:
                                                                          context,
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }).show();
                                                                } else {
                                                                  throw new Exception(
                                                                      "error");
                                                                }
                                                              } catch (e) {
                                                                setState(() {
                                                                  disableTextFields =
                                                                      false;
                                                                });
                                                                MessageAlertDialog(
                                                                    message:
                                                                        "Unable to add client, please try again.",
                                                                    context:
                                                                        context,
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context)).show();
                                                              }
                                                            },
                                                            buttonText:
                                                                "add client",
                                                            isLoading: false,
                                                            backgroundColor:
                                                                'green'),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )))))))),
                  BottomBar(
                      visble: bottomBarVisible,
                      controller: bottomBarAnimationController,
                      deleteImage: () {
                        print(imageSrc.path);
                        if (imageSrc == null) {
                          setState(() {
                            bottomBarVisible = false;
                          });
                          return;
                        }

                        AreYouSureAlertDialog(
                          context: context,
                          message:
                              "Are you sure you want to remove this image?",
                          leftButtonText: "no",
                          rightButtonText: "yes",
                          onLeftButton: () {
                            Navigator.of(context).pop();
                          },
                          onRightButton: () {
                            setState(() {
                              imageSrc = null;
                              bottomBarVisible = false;
                            });
                            Navigator.of(context).pop();
                          },
                        ).show();
                      },
                      openCamera: () async {
                        File tempImageSrc = imageSrc;
                        imageSrc =
                            await FileAndImageFunctions.openNativeCamera();
                        setState(() {
                          if (imageSrc == null) {
                            imageSrc = tempImageSrc;
                          } else {
                            bottomBarVisible = false;
                          }
                        });
                      },
                      openGallery: () async {
                        File tempImageSrc = imageSrc;
                        imageSrc =
                            await FileAndImageFunctions.openImagePicker();
                        setState(() {
                          if (imageSrc == null) {
                            imageSrc = tempImageSrc;
                          } else {
                            bottomBarVisible = false;
                          }
                        });
                      })
                ]))));
  }
}

Future<bool> addClient({
  String firstName,
  String lastName,
  String email,
  String phoneNumber,
  File clientImage,
  GlobalKey<FormState> formKey,
}) async {
  try {
    if (!formKey.currentState.validate()) {
      return false;
    }
    final ClientModel clientModel = ClientModel(
        clientFirstName: firstName,
        clientLastName: lastName,
        clientEmail: email,
        clientPhoneNumber: phoneNumber,
        clientImage: clientImage);
    print(clientImage);
    // List<ClientModel> clients = await clientModel.readClients();
    // clients.asMap().forEach((key, value) {
    // print("$key : ${value.map}");
    // });
    bool query = await clientModel.insertClient(clientModel);
    print("query $query");
    return query;
  } catch (e) {
    print(e);
  }
}
