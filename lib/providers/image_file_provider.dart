import 'dart:io';

import 'package:beauty_fyi/container/alert_dialoges/are_you_sure_alert_dialog.dart';
import 'package:beauty_fyi/functions/file_and_image_functions.dart';
import 'package:beauty_fyi/providers/slide_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final slideValidationNotifierProvider =
    StateNotifierProvider((ref) => SlideValidatedNotifier());

abstract class ImageFileState {
  const ImageFileState();
}

class ImageFileInitial extends ImageFileState {
  const ImageFileInitial();
}

class ImageFileLoading extends ImageFileState {
  const ImageFileLoading();
}

class ImageFileLoaded extends ImageFileState {
  final File file;
  const ImageFileLoaded(this.file);
}

class ImageFileError extends ImageFileState {
  final String message;
  const ImageFileError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ImageFileError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ImageFileNotifier<ImageFileState> extends StateNotifier {
  ImageFileNotifier(String? url, [ImageFileState? state])
      : super(ImageFileInitial()) {
    setImageFile(null, url);
  }
  File? imageFile;
  Future<void> setImageFile(File? file, String? url) async {
    try {
      if (file != null) {
        if (file.existsSync()) {
          print("setting new file");
          imageFile = file;
          state = ImageFileLoaded(imageFile as File);
          return;
        }
      }
      if (url != null) {
        // this is just used for clients right now
        final response = await http.get(Uri.parse(url));
        final _ = await getTemporaryDirectory();
        final file = File(join(_.path, "placeholder.png"));
        file.writeAsBytesSync(response.bodyBytes);
        imageFile = file;
        state = ImageFileLoaded(imageFile as File);
        return;
      } else {
        state = ImageFileInitial();
        return;
      }
    } catch (e) {
      print(e);
      state = ImageFileError("No image file found");
    }
    return;
  }

  Future<void> clearImageFile(context) async {
    AreYouSureAlertDialog(
      context: context,
      message: "Are you sure you want to remove this image?",
      leftButtonText: "no",
      rightButtonText: "yes",
      onLeftButton: () {
        Navigator.of(context).pop();
      },
      onRightButton: () {
        imageFile = null;
        state = ImageFileInitial();
        Navigator.of(context).pop();
      },
    ).show();
    return;
  }

  void softDispose() {
    state = ImageFileInitial;
    imageFile = null;
  }
}
