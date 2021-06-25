import 'dart:convert';
import 'dart:io';

import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/create_service/service_image/action_button.dart';
import 'package:beauty_fyi/container/create_service/service_image/gallery_icon_stack.dart';
import 'package:beauty_fyi/container/create_service/service_image/progress_circles.dart';
import 'package:beauty_fyi/container/full_screen_image/bottom_bar.dart';
import 'package:beauty_fyi/container/textfields/default_textarea.dart';
import 'package:beauty_fyi/container/textfields/default_textfield.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/providers/addService/add_service_provider.dart';
import 'package:beauty_fyi/providers/addService/service_name_provider.dart';
import 'package:beauty_fyi/providers/addService/service_process_provider.dart';
import 'package:beauty_fyi/providers/bottom_bar_provider.dart';
import 'package:beauty_fyi/providers/image_file_provider.dart';
import 'package:beauty_fyi/providers/slide_validation_provider.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addServiceNotifierProvider = StateNotifierProvider.autoDispose((ref) {
  return AddServiceNotifier();
});
final bottomBarNotfierProvider =
    StateNotifierProvider.autoDispose((ref) => BottomBarNotifier());
final imageFileNotifierProvider =
    StateNotifierProvider((ref) => ImageFileNotifier());
final serviceProcessNotifierProvider =
    StateNotifierProvider((ref) => ServiceProcessNotifier());
final serviceNameNotifierProvider =
    StateNotifierProvider((ref) => ServiceNameNotifier());
final slideValidationNotifierProvider =
    StateNotifierProvider.autoDispose((ref) => SlideValidatedNotifier());
final slideIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class CreateServiceScreen extends StatelessWidget {
  final args;
  CreateServiceScreen({Key? key, this.args}) : super(key: key);
  final List<Widget> slides = [
    _ChooseImageSlide(),
    _ServiceNameSlide(),
    _ServiceProcessSlide()
  ];
  final List<String> slideLabels = [
    "Service Image",
    "Service details",
    "Service Process"
  ];

  @override
  Widget build(BuildContext context) {
    final bottomBarNotifierController =
        context.read(bottomBarNotfierProvider.notifier);
    final addServiceNotifierController =
        context.read(addServiceNotifierProvider.notifier);
    final slideIndexController = context.read(slideIndexProvider);
    final serviceNameNotifierController =
        context.read(serviceNameNotifierProvider.notifier);
    final serviceProcessNotifierController =
        context.read(serviceProcessNotifierProvider.notifier);
    final imageFileNotifierController =
        context.read(imageFileNotifierProvider.notifier);
    final height = MediaQuery.of(context).size.height - 170;
    int serviceId = 0; // if service ID is not 0, then the service will update
    final PageController _pageController =
        PageController(initialPage: slideIndexController.state);
    if (args != null) {
      serviceId = args['id'];
      _recallServiceData(addServiceNotifierController, context, serviceId);
    }
    return Consumer(builder: (BuildContext context, watch, child) {
      final state = watch(addServiceNotifierProvider);
      return new WillPopScope(
          onWillPop: () {
            if (bottomBarNotifierController.isVisible) {
              bottomBarNotifierController.hideBottomBar();
              return Future.value(false);
            }
            if (slideIndexController.state > 0) {
              slideIndexController.state--;
              _pageController.animateToPage(
                  context.read(slideIndexProvider).state,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOutCirc);
              return Future.value(false);
            }
            serviceNameNotifierController.softDispose();
            serviceProcessNotifierController.softDispose();
            imageFileNotifierController.softDispose();
            return Future.value(true);
          },
          child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: CustomAppBar(
                  focused: true,
                  transparent: true,
                  titleText: "",
                  leftIcon: Icons.arrow_back,
                  showMenuIcon: false,
                  leftIconClicked: () {
                    if (bottomBarNotifierController.isVisible) {
                      bottomBarNotifierController.hideBottomBar();
                    }
                    if (slideIndexController.state > 0) {
                      slideIndexController.state--;
                      _pageController.animateToPage(
                          context.read(slideIndexProvider).state,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCirc);
                    } else {
                      Navigator.pop(context);
                    }
                  },
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
                  GestureDetector(
                    onTap: () {
                      if (bottomBarNotifierController.isVisible) {
                        bottomBarNotifierController.hideBottomBar();
                      }
                    },
                    child: AnimatedOpacity(
                      opacity: bottomBarNotifierController.isVisible ? 0.2 : 1,
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
                                  Expanded(
                                    child: PageView(
                                      key: GlobalKey(),
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      controller: _pageController,
                                      onPageChanged: (value) {},
                                      children: [
                                        slides[0],
                                        slides[1],
                                        slides[2],
                                      ],
                                    ),
                                  ),
                                  Consumer(builder: (context, watch, child) {
                                    final provider = watch(slideIndexProvider);
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        slideLabels[provider.state],
                                        style: TextStyle(
                                          color: Colors.black87,
                                          letterSpacing: 1.5,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'OpenSans',
                                        ),
                                      ),
                                    );
                                  }),
                                  Consumer(
                                    builder: (context, watch, child) {
                                      // final serviceNameNotifierController =
                                      // context.read(serviceNameNotifierProvider
                                      // .notifier);
                                      // final serviceProcessNotifierController =
                                      // context.read(
                                      // serviceProcessNotifierProvider
                                      // .notifier);
                                      // final imageFileNotifierController =
                                      // context.read(
                                      // imageFileNotifierProvider.notifier);
                                      final validationState = watch(
                                          slideValidationNotifierProvider);

                                      return ActionButton(
                                        backgroundColor:
                                            validationState is SlideValidation
                                                ? validationState.isValidated
                                                    ? 'darker_green'
                                                    : 'green'
                                                : 'green',
                                        buttonText:
                                            validationState is SlideValidation
                                                ? validationState.isValidated
                                                    ? "continue"
                                                    : ""
                                                : "",
                                        onPressed: () async {
                                          serviceNameNotifierController
                                              .serviceNameTextFieldFocusNode
                                              .unfocus();
                                          serviceNameNotifierController
                                              .serviceDescriptionTextFieldFocusNode
                                              .unfocus();
                                          bottomBarNotifierController
                                              .hideBottomBar();
                                          validationState is SlideValidation
                                              ? validationState.isValidated
                                                  ? () {
                                                      switch (context
                                                          .read(
                                                              slideIndexProvider)
                                                          .state) {
                                                        case 2:
                                                          addServiceNotifierController.sendQuery(
                                                              servicemodel: ServiceModel(
                                                                  id: serviceId,
                                                                  serviceName:
                                                                      serviceNameNotifierController
                                                                          .serviceNameTextFieldController
                                                                          .text,
                                                                  serviceDescription:
                                                                      serviceNameNotifierController
                                                                          .serviceDescriptionTextFieldController
                                                                          .text,
                                                                  imageSrc:
                                                                      imageFileNotifierController
                                                                          .imageFile,
                                                                  serviceProcesses: json.encode(serviceProcessNotifierController
                                                                      .serviceProcesses
                                                                      .map((e) => e
                                                                          .toMap)
                                                                      .toList())),
                                                              updating:
                                                                  serviceId !=
                                                                      0,
                                                              context: context);
                                                          break;
                                                        default:
                                                          context
                                                              .read(
                                                                  slideIndexProvider)
                                                              .state++;
                                                          _pageController.animateToPage(
                                                              context
                                                                  .read(
                                                                      slideIndexProvider)
                                                                  .state,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      400),
                                                              curve: Curves
                                                                  .easeOutCirc);
                                                          break;
                                                      }
                                                      //problem is we need to check if every slide is validated when we enter
                                                      // addServiceNotifierController.recallServiceObject['recalled'] ? null : slideValidationNotifierController;
                                                    }()
                                                  // set slide to not validated
                                                  // if slide index is 2 then send query
                                                  // json.encode(serviceProcesses));
                                                  : null
                                              : null;
                                          //validate form if slide is index 1??? might not have to
                                          // serviceNameForm.currentState!
                                          // .validate();
                                          //
                                          //
                                          // slide index = 2 ? send query
                                        },
                                        isLoading: false,
                                      );
                                    },
                                  ),
                                  Consumer(
                                    builder: (context, watch, child) {
                                      final provider =
                                          watch(slideIndexProvider);
                                      return ProgressCircles(
                                        circleAmount: provider.state,
                                        currentIndex:
                                            slideIndexController.state,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BottomBar(),
                ]),
              )));
    });
  }
}

class _ChooseImageSlide extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final bottomBarNotifierController =
        context.read(bottomBarNotfierProvider.notifier);
    final imageFileNotifierController =
        context.read(imageFileNotifierProvider.notifier);
    final slideValidationNotifierController =
        context.read(slideValidationNotifierProvider.notifier);
    // final state = watch(imageFileNotifierProvider);
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    // try {
    // state is ImageFileLoaded
    // ? slideValidationNotifierController.validateSlide(true)
    // : slideValidationNotifierController.validateSlide(false);
    // } catch (e) {
    // print(e);
    // }
    // });

    /*return Column(
        key: ValueKey<int>(0),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GalleryIconStack(
            size: GalleryIconSize.Big,
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
                  ? imageFileNotifierController.clearImageFile(context)
                  : imageFileNotifierController.setImageFile(returnedImage);
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
        ]);*/
    return Container(
      child: Text("hey"),
    );
  }
}

class _ServiceNameSlide extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final serviceNameNotifierController =
        context.read(serviceNameNotifierProvider.notifier);
    final slideValidationNotifierController =
        context.read(slideValidationNotifierProvider.notifier);
    final state = watch(serviceNameNotifierProvider);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      state is ServiceNameValidation
          ? state.isValidated
              ? slideValidationNotifierController.validateSlide(true)
              : slideValidationNotifierController.validateSlide(false)
          : slideValidationNotifierController.validateSlide(false);
    });
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Form(
        key: serviceNameNotifierController.serviceNameForm,
        autovalidateMode:
            serviceNameNotifierController.autovalidateModeServiceName,
        child: Column(
          children: [
            DefaultTextField(
              focusNode:
                  serviceNameNotifierController.serviceNameTextFieldFocusNode,
              iconData: null,
              hintText: "",
              invalidMessage: "Invalid name",
              labelText: "Service name",
              textInputType: TextInputType.name,
              defaultTextFieldController:
                  serviceNameNotifierController.serviceNameTextFieldController,
              disableTextFields:
                  serviceNameNotifierController.disableTextFields,
              stylingIndex: 1,
              regex: serviceNameNotifierController.serviceNameRegexString,
              validationStringLength: 4,
              validate: true,
            ),
            SizedBox(
              height: 10,
            ),
            DefaultTextArea(
              focusNode: serviceNameNotifierController
                  .serviceDescriptionTextFieldFocusNode,
              iconData: null,
              hintText: "",
              invalidMessage: "Invalid name",
              labelText: "Service description",
              textInputType: TextInputType.name,
              defaultTextAreaController: serviceNameNotifierController
                  .serviceDescriptionTextFieldController,
              disableTextFields:
                  serviceNameNotifierController.disableTextFields,
              stylingIndex: 1,
            )
          ],
        ),
      ),
      key: ValueKey<int>(1),
    );
  }
}

class _ServiceProcessSlide extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final state = watch(serviceProcessNotifierProvider);
    final serviceProcessNotifierController =
        context.read(serviceProcessNotifierProvider.notifier);
    final slideValidationNotifierController =
        context.read(slideValidationNotifierProvider.notifier);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      state is ServiceProcessLoaded
          ? state.serviceProcesses.isNotEmpty
              ? slideValidationNotifierController.validateSlide(true)
              : slideValidationNotifierController.validateSlide(false)
          : slideValidationNotifierController.validateSlide(false);
    });
    return Container(
      child: Column(
        children: <Widget>[
          Container(
              height: 260,
              child: state is ServiceProcessLoading
                  ? Center(child: CircularProgressIndicator())
                  : state is ServiceProcessLoaded
                      ? state.serviceProcesses.length == 0
                          ? Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Add the processes that make up your service.",
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
                              itemCount: state.serviceProcesses.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    key: ValueKey(index),
                                    onTap: () =>
                                        serviceProcessNotifierController
                                            .displayProcessTextInput(
                                                context: context, index: index),
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                text: "${index + 1})",
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        ' ${state.serviceProcesses[index].processName}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        ' ${state.serviceProcesses[index].processDuration}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'OpenSans',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' min(s)',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'OpenSans',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child:
                                                      Icon(Icons.drag_handle)))
                                        ],
                                      ),
                                    ));
                              },
                              onReorder: (oldIndex, newIndex) =>
                                  serviceProcessNotifierController.reorderList(
                                      oldIndex, newIndex),
                            )
                      : Container() // error or initial,
              ),
          Column(
            children: [
              MaterialButton(
                onPressed: () => serviceProcessNotifierController
                    .displayProcessTextInput(context: context),
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
                padding: EdgeInsets.only(top: 0),
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
  }
}

class _BottomBar extends StatefulWidget {
  @override
  __BottomBarState createState() => __BottomBarState();
}

class __BottomBarState extends State<_BottomBar> with TickerProviderStateMixin {
  late AnimationController bottomBarAnimationController;

  @override
  void initState() {
    bottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    super.initState();
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
        final imageFileNotifierController =
            context.read(imageFileNotifierProvider.notifier);
        final state = watch(bottomBarNotfierProvider);
        return BottomBar(
            visble: state is BottomBarVisibility ? state.isVisible : false,
            controller: bottomBarAnimationController,
            deleteImage: () =>
                imageFileNotifierController.clearImageFile(context),
            // bottomBarVisible = false;
            // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            openCamera: () async {
              imageFileNotifierController
                  .setImageFile(await FileAndImageFunctions.openNativeCamera());
              // bottomBarVisible = false;
              // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            },
            openGallery: () async {
              imageFileNotifierController
                  .setImageFile(await FileAndImageFunctions.openImagePicker());
              // bottomBarVisible = false;
              // slideValidated = isSlideValid(slideIndex: 0, imageSrc: imageSrc);
            });
      },
    );
  }
}

void _recallServiceData(AddServiceNotifier addServiceNotifierController,
    BuildContext context, int id) {
  final imageFileNotifierController =
      context.read(imageFileNotifierProvider.notifier);
  final serviceNameNotifierController =
      context.read(serviceNameNotifierProvider.notifier);
  final serviceProcessNotifierController =
      context.read(serviceProcessNotifierProvider.notifier);
  addServiceNotifierController.recallServiceData(id).then((value) {
    imageFileNotifierController.setImageFile(value['imageFile']);
    serviceNameNotifierController.serviceNameTextFieldController.text =
        value['serviceName'];
    serviceNameNotifierController.serviceDescriptionTextFieldController.text =
        value['serviceDescription'];
    serviceProcessNotifierController.addServiceProcesses =
        value['serviceProcesses'];
    print("is data being recalled?");
  }).onError((error, stackTrace) => null);
}
