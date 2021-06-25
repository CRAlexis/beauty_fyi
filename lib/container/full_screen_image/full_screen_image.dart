import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/container/app_bar/sliding_app_bar.dart';
import 'package:beauty_fyi/container/full_screen_image/bottom_bar.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatefulWidget {
  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage>
    with TickerProviderStateMixin {
  bool appBarVisible = false;
  bool bottomBarVisible = false;
  AnimationController? appBarAnimationController;
  AnimationController? bottomBarAnimationController;

  @override
  void initState() {
    super.initState();
    appBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    bottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    appBarAnimationController!.dispose();
    bottomBarAnimationController!.dispose();
    super.dispose();
  }

  File? imageSrc;
  bool imageHasUpdated = false;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return new WillPopScope(
        onWillPop: () {
          if (bottomBarVisible) {
            setState(() {
              bottomBarVisible = !bottomBarVisible;
            });
            return Future.value(false);
          } else {
            Navigator.pop(context, {
              'override': imageHasUpdated,
              'imageSrc':
                  (imageSrc == null && arguments!['imageSrc'] == null) ||
                          (imageSrc == null && imageHasUpdated == true)
                      ? null
                      : imageSrc != null
                          ? imageSrc
                          : arguments!['imageSrc']
            });
            return Future.value(true);
          }
        },
        child: Scaffold(
            extendBodyBehindAppBar:
                true, // Uses entire screen after hiding AppBar
            appBar: SlidingAppBar(
              controller: appBarAnimationController,
              visible: appBarVisible,
              child: CustomAppBar(
                  focused: !bottomBarVisible,
                  transparent: true,
                  titleText: "",
                  leftIcon: Icons.arrow_back,
                  showMenuIcon: true,
                  menuOptions: ['edit'],
                  menuIconClicked: (String val) {
                    switch (val) {
                      case 'edit':
                        setState(() => bottomBarVisible = !bottomBarVisible);
                        break;
                      default:
                    }
                  },
                  leftIconClicked: () {
                    if (bottomBarVisible) {
                      setState(() {
                        bottomBarVisible = false;
                      });
                    } else {
                      Navigator.pop(context, {
                        'imageHasUpdated': imageHasUpdated,
                        'imageSrc': (imageSrc == null &&
                                    arguments!['imageSrc'] == null) ||
                                (imageSrc == null && imageHasUpdated == true)
                            ? null
                            : imageSrc != null
                                ? imageSrc
                                : arguments!['imageSrc'],
                      });
                    }
                  },
                  automaticallyImplyLeading: false),
            ),
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (bottomBarVisible) {
                      setState(() => bottomBarVisible = !bottomBarVisible);
                    } else {
                      setState(() => appBarVisible = !appBarVisible);
                    }
                  },
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: bottomBarVisible ? 0.2 : 1,
                            child: Hero(
                                tag: "arguments['hero_index']",
                                child: (imageSrc == null &&
                                            arguments!['imageSrc'] == null) ||
                                        (imageSrc == null &&
                                            imageHasUpdated == true)
                                    ? Icon(
                                        Icons.image,
                                        size: 200,
                                        color: Colors.white,
                                      )
                                    : imageSrc != null
                                        ? Image.file(imageSrc!)
                                        : Image.file(arguments!['imageSrc'])),
                          ))),
                ),
                BottomBar(
                    visble: bottomBarVisible,
                    controller: bottomBarAnimationController,
                    deleteImage: () {
                      if (imageSrc == null && arguments!['imageSrc'] == null) {
                        setState(() {
                          bottomBarVisible = false;
                        });
                        return;
                      }
                      AreYouSureAlertDialog(
                        context: context,
                        message: "Are you sure you want to remove this image?",
                        leftButtonText: "no",
                        rightButtonText: "yes",
                        onLeftButton: () {
                          Navigator.of(context).pop();
                        },
                        onRightButton: () {
                          setState(() {
                            imageSrc = null;
                            imageHasUpdated = true;
                            bottomBarVisible = false;
                            Navigator.of(context).pop();
                          });
                        },
                      ).show();
                    },
                    openCamera: () async {
                      File? tempImageSrc =
                          imageSrc != null ? imageSrc : arguments!['imageSrc'];
                      imageSrc = await FileAndImageFunctions.openNativeCamera();
                      setState(() {
                        if (imageSrc == null) {
                          imageSrc = tempImageSrc;
                        } else {
                          imageHasUpdated = true;
                          bottomBarVisible = false;
                        }
                      });
                    },
                    openGallery: () async {
                      File? tempImageSrc =
                          imageSrc != null ? imageSrc : arguments!['imageSrc'];
                      imageSrc = await FileAndImageFunctions.openImagePicker();
                      setState(() {
                        if (imageSrc == null) {
                          imageSrc = tempImageSrc;
                        } else {
                          imageHasUpdated = true;
                          bottomBarVisible = false;
                        }
                      });
                    })
              ],
            )));
  }
}
