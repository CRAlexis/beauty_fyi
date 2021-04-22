import 'dart:convert';
import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/loading_alert_dialog.dart';
import 'package:beauty_fyi/container/alert_dialoges/message_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/create_service/service_image/action_button.dart';
import 'package:beauty_fyi/container/create_service/service_image/gallery_icon_stack.dart';
import 'package:beauty_fyi/container/create_service/service_image/progress_circles.dart';
import 'package:beauty_fyi/container/full_screen_image/bottom_bar.dart';
import 'package:beauty_fyi/container/textfields/default_textarea.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:beauty_fyi/extensions/string_extension.dart';

class CreateServiceScreen extends StatefulWidget {
  final args;
  const CreateServiceScreen({Key key, this.args}) : super(key: key);
  @override
  _CreateServiceScreenState createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen>
    with TickerProviderStateMixin {
  final serviceNameForm = GlobalKey<FormState>();
  final serviceProcessForm = GlobalKey<FormState>();
  final serviceNameTextFieldController = TextEditingController();
  final serviceDescriptionTextFieldController = TextEditingController();

  AnimationController bottomBarAnimationController;
  String serviceNamevalue = "";
  String serviceDescriptionValue = "";
  bool disableTextFields = false;
  bool bottomBarVisible = false;
  bool slideValidated = false;
  bool switchColours = false;
  File imageSrc;
  bool pageHasAlreadyRecalled = false;
  List<Color> backgroundColours = [
    colorStyles['dark_purple'],
    colorStyles['light_purple'],
    colorStyles['blue'],
    colorStyles['green']
  ];
  List<String> slideLabels = [
    "Service Image",
    "Service details",
    "Service Process"
  ];
  // servicePrcossMap['test'] = 10;
  int slideIndex = 0;

  List<Map<String, int>> serviceProcesses = [];

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

  Future<void> recallServiceData({id}) async {
    final service = await fetchService(id: id);
    // print(service);
    serviceNameTextFieldController.text = service['service_name'];
    serviceDescriptionTextFieldController.text = service['service_description'];
    serviceNamevalue = service['service_name'];
    serviceDescriptionValue = service['service_description'];
    imageSrc = File(service['service_image']);
    List<dynamic> list = json.decode(service['service_processes']);
    for (var map in list) {
      var key;
      var value;
      for (key in map.keys) key = key;
      for (value in map.values) value = value;
      serviceProcesses.add({key: value});
    }
    print(serviceProcesses);
    slideValidated = true;
    pageHasAlreadyRecalled = true;
    return;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.args != null && !pageHasAlreadyRecalled) {
      recallServiceData(id: widget.args['id']).then((value) {
        setState(() {});
      });
    }
    Future<void> displayProcessTextInput({BuildContext context, index}) {
      String processNameValidationError;
      String processDurationValidationError;
      TextEditingController processNameController = TextEditingController();
      TextEditingController processDurationController = TextEditingController();
      AutovalidateMode processFormAutovalidateMode =
          AutovalidateMode.onUserInteraction;
      processNameValidationError = "Invalid name";
      processDurationValidationError = "Invalid duration";

      if (index != null) {
        processNameController.text = serviceProcesses[index].keys.first;
        processDurationController.text =
            serviceProcesses[index].values.first.toString();
      }
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              scrollable: true,
              title: Text("Service process"),
              content: Container(
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
                      labelText: "Process name",
                      textInputType: TextInputType.text,
                      defaultTextFieldController: processNameController,
                      onSaved: (String value) {},
                      onChanged: (String value) {},
                      disableTextFields: false,
                      stylingIndex: 2,
                      regex: r'^[a-zA-Z ]+$',
                      height: 40,
                      labelPadding: 0,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DefaultTextField(
                        iconData: null,
                        hintText: "",
                        invalidMessage: processDurationValidationError,
                        labelText: "Process duration",
                        textInputType: TextInputType.number,
                        defaultTextFieldController: processDurationController,
                        onSaved: (String value) {},
                        onChanged: (String value) {},
                        disableTextFields: false,
                        stylingIndex: 2,
                        regex: r'[1-9]',
                        height: 40,
                        labelPadding: 0,
                        suffixText: "(Minutes)",
                        validationStringLength: 1),
                  ],
                ),
              )),
              actions: <Widget>[
                index != null
                    ? TextButton(
                        child: Text('REMOVE'),
                        onPressed: () {
                          setState(() {
                            serviceProcesses.removeAt(index);
                            processDurationController.text = "";
                            processNameController.text = "";
                            Navigator.pop(context);
                          });
                        },
                      )
                    : null,
                TextButton(
                  child: Text('ADD'),
                  onPressed: () {
                    setState(() {
                      serviceProcessForm.currentState.validate();
                      if (serviceProcessForm.currentState.validate()) {
                        if (index != null) {
                          serviceProcesses.removeAt(index);
                          serviceProcesses.insert(index, {
                            processNameController.text:
                                int.parse(processDurationController.text)
                          });
                        } else {
                          serviceProcesses.add({
                            processNameController.text:
                                int.parse(processDurationController.text)
                          });
                        }
                        if (serviceProcesses.length > 0) {
                          slideValidated = isSlideValid(
                              slideIndex: 2,
                              serviceProcesses: serviceProcesses);
                        }
                        Navigator.pop(context);
                      }
                    });
                  },
                ),
              ],
            );
          });
    }

    final height = MediaQuery.of(context).size.height - 170;
    Widget chooseImageWidget = Column(
        key: ValueKey<int>(0),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GalleryIconStack(
            imageSrc: imageSrc,
            onPreviewImage: () {
              if (bottomBarVisible) {
                setState(() {
                  bottomBarVisible = !bottomBarVisible;
                });
                return;
              }
              Navigator.pushNamed(context, "/full-screen-image",
                  arguments: {'imageSrc': imageSrc}).then((value) {
                File returnedImage =
                    (value as Map<String, dynamic>)['imageSrc'];
                bool override = (value as Map<String, dynamic>)['override'];
                setState(() {
                  if (returnedImage != null) {
                    imageSrc = returnedImage;
                    slideValidated =
                        isSlideValid(slideIndex: 0, imageSrc: imageSrc);
                  } else {
                    if (override) {
                      imageSrc = null;
                      slideValidated =
                          isSlideValid(slideIndex: 0, imageSrc: imageSrc);
                    }
                  }
                });
              });
            },
            onOpenGalleryOrCamera: () {
              if (bottomBarVisible) {
                setState(() {
                  bottomBarVisible = !bottomBarVisible;
                });
                return;
              }
              setState(() {
                bottomBarVisible = !bottomBarVisible;
              });
              //open camera
            },
          ),
        ]);

    Widget serviceNameWidget = Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Form(
        key: serviceNameForm,
        child: Column(
          children: [
            DefaultTextField(
              iconData: null,
              hintText: "",
              invalidMessage: "Invalid name",
              labelText: "Service name",
              textInputType: TextInputType.name,
              defaultTextFieldController: serviceNameTextFieldController,
              onSaved: (String value) {
                serviceNamevalue = value;
              },
              onChanged: (String value) {
                serviceNamevalue = value;
                if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(serviceNamevalue) &&
                    serviceNamevalue.length < 3) {
                  slideValidated = isSlideValid(
                      slideIndex: 1, serviceName: serviceNamevalue);
                } else {
                  slideValidated = isSlideValid(
                      slideIndex: 1, serviceName: serviceNamevalue);
                }
              },
              disableTextFields: disableTextFields,
              stylingIndex: 1,
              regex: r'^[a-zA-Z ]+$',
            ),
            SizedBox(
              height: 10,
            ),
            DefaultTextArea(
              iconData: null,
              hintText: "",
              invalidMessage: "Invalid name",
              labelText: "Service description",
              textInputType: TextInputType.name,
              defaultTextAreaController: serviceDescriptionTextFieldController,
              onSaved: (String value) {
                serviceNamevalue = value;
              },
              onChanged: (String value) {
                serviceDescriptionValue = value;
              },
              disableTextFields: disableTextFields,
              stylingIndex: 1,
            )
          ],
        ),
      ),
      key: ValueKey<int>(1),
    );

    Widget serviceProcessWidget = Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 240,
            child: serviceProcesses.length == 0
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add all the processes that make up your service.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Opensans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: serviceProcesses.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          key: ValueKey(index),
                          onTap: () => displayProcessTextInput(
                              context: context, index: index),
                          child: Container(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      text: "${index + 1})",
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              ' ${serviceProcesses[index].keys.first.capitalize()}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'OpenSans',
                                              fontSize: 16),
                                        ),
                                        TextSpan(
                                          text: ' for',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'OpenSans',
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${serviceProcesses[index].values.first}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'OpenSans',
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' mins',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'OpenSans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.drag_handle)))
                              ],
                            ),
                          ));
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex = newIndex - 1;
                        }
                        final element = serviceProcesses.removeAt(oldIndex);
                        serviceProcesses.insert(newIndex, element);
                      });
                    },
                  ),
          ),
          Column(
            children: [
              MaterialButton(
                onPressed: () => displayProcessTextInput(context: context),
                color: Colors.blue,
                textColor: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 22,
                ),
                padding: EdgeInsets.all(8),
                shape: CircleBorder(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Add process",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      key: ValueKey<int>(2),
    );
    List<Widget> slides = [
      chooseImageWidget,
      serviceNameWidget,
      serviceProcessWidget
    ];

    return new WillPopScope(
        onWillPop: () {
          if (bottomBarVisible) {
            setState(() {
              bottomBarVisible = !bottomBarVisible;
            });
            return Future.value(false);
          }
          if (slideIndex > 0) {
            setState(() {
              slideIndex--;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
                focused: true,
                transparent: true,
                titleText: "",
                leftIcon: Icons.arrow_back,
                rightIcon: Icons.info,
                leftIconClicked: () {
                  if (bottomBarVisible) {
                    setState(() {
                      bottomBarVisible = !bottomBarVisible;
                    });
                  }
                  if (slideIndex > 0) {
                    setState(() {
                      slideIndex--;
                      slideValidated = isSlideValid(
                          slideIndex: slideIndex,
                          imageSrc: imageSrc,
                          serviceName: serviceNamevalue,
                          serviceProcesses: serviceProcesses);
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                rightIconClicked: () {},
                automaticallyImplyLeading: false),
            body: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  gradient: switchColours
                      ? LinearGradient(colors: [
                          colorStyles['dark_purple'],
                          colorStyles['light_purple'],
                          colorStyles['blue'],
                          colorStyles['green']
                        ], begin: Alignment.topLeft, end: Alignment.bottomRight)
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
                    duration: Duration(microseconds: 500),
                    child: Container(
                      height: double.infinity,
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
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                        child: child, opacity: animation);
                                  },
                                  duration: Duration(milliseconds: 100),
                                  child: slides[slideIndex],
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    slideLabels[slideIndex],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      letterSpacing: 1.5,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                ),
                                ActionButton(
                                  backgroundColor:
                                      slideValidated ? 'darker_green' : 'green',
                                  buttonText: slideValidated ? "continue" : "",
                                  onPressed: () async {
                                    setState(() {
                                      // loadingAlertDialog.show();
                                      // loadingAlertDialog.pop();
                                      switchColours = !switchColours;
                                      switch (slideIndex) {
                                        case 0:
                                          slideIndex++;
                                          break;
                                        case 1:
                                          //validate form
                                          serviceNameForm.currentState
                                              .validate();
                                          slideIndex++;
                                          slideValidated = false;
                                          break;
                                        case 2:
                                          try {
                                            final loadingAlertDialog =
                                                LoadingAlertDialog(
                                                    context: context,
                                                    message:
                                                        "Creating service");
                                            loadingAlertDialog.show();
                                            final service = ServiceModel(
                                                id: widget.args['id'],
                                                serviceName: serviceNamevalue,
                                                serviceDescription:
                                                    serviceDescriptionValue,
                                                imageSrc: imageSrc,
                                                serviceProcesses: json
                                                    .encode(serviceProcesses));
                                            sendQuery(
                                                    servicemodel: service,
                                                    updating:
                                                        pageHasAlreadyRecalled)
                                                .then((value) {
                                              loadingAlertDialog.pop();
                                              MessageAlertDialog(
                                                context: context,
                                                message:
                                                    "Created service successfully",
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                          context,
                                                          "/dashboard",
                                                          (r) => false);
                                                },
                                              ).show();
                                            }).catchError((error, stacktrace) {
                                              loadingAlertDialog.pop();
                                              MessageAlertDialog(
                                                  context: context,
                                                  message:
                                                      "Failed to create service",
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }).show();
                                              print("error: $error");
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                          break;
                                        default:
                                      }
                                      slideValidated = isSlideValid(
                                          slideIndex: slideIndex,
                                          imageSrc: imageSrc,
                                          serviceName: serviceNamevalue,
                                          serviceProcesses: serviceProcesses);
                                    });
                                  },
                                  isLoading: false,
                                ),
                                ProgressCircles(
                                  circleAmount: 3,
                                  currentIndex: slideIndex,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                BottomBar(
                    visble: bottomBarVisible,
                    controller: bottomBarAnimationController,
                    deleteImage: () {
                      if (imageSrc == null) {
                        setState(() {
                          bottomBarVisible = false;
                        });
                        return;
                      }
                      AreYouSureAlertDialog(
                        message: "Are you sure you want to remove this image?",
                        leftButtonText: "no",
                        rightButtonText: "yes",
                        onLeftButton: () {
                          Navigator.of(context).pop();
                        },
                        onRightButton: () {
                          setState(() {
                            imageSrc = null;
                            bottomBarVisible = false;
                            slideValidated =
                                isSlideValid(slideIndex: 0, imageSrc: imageSrc);
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    openCamera: () async {
                      File tempImageSrc = imageSrc;
                      imageSrc = await FileAndImageFunctions.openNativeCamera();
                      setState(() {
                        if (imageSrc == null) {
                          imageSrc = tempImageSrc;
                        } else {
                          bottomBarVisible = false;
                          slideValidated =
                              isSlideValid(slideIndex: 0, imageSrc: imageSrc);
                        }
                      });
                    },
                    openGallery: () async {
                      File tempImageSrc = imageSrc;
                      imageSrc = await FileAndImageFunctions.openImagePicker();
                      setState(() {
                        if (imageSrc == null) {
                          imageSrc = tempImageSrc;
                        } else {
                          bottomBarVisible = false;
                          slideValidated =
                              isSlideValid(slideIndex: 0, imageSrc: imageSrc);
                        }
                      });
                    })
              ]),
            )));
  }
}

bool isSlideValid(
    {slideIndex,
    imageSrc,
    serviceName,
    serviceProcesses,
    hasRecalledData = false}) {
  if (hasRecalledData) {
    return true;
  }
  switch (slideIndex) {
    case 0:
      if (imageSrc != null) {
        return true;
      }
      break;
    case 1:
      if ((!RegExp(r'/^[A-Za-z\s]+$/').hasMatch(serviceName) &&
          serviceName.length < 3)) {
      } else {
        return true;
      }
      break;
    case 2:
      if (serviceProcesses.length > 0) {
        return true;
      }
  }
  return false;
}

Future<Map<String, dynamic>> fetchService({id}) async {
  final serviceModel = new ServiceModel(id: id);
  print("refreshing future");
  return await serviceModel.readService();
}

Future<void> sendQuery({ServiceModel servicemodel, bool updating}) async {
  try {
    updating
        ? await servicemodel.updateService(servicemodel)
        : await servicemodel.insertService(servicemodel);
    return;
  } catch (e) {
    Future.error(e, StackTrace.fromString(""));
  }
}
