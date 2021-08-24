import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';

class FileAndImageFunctions {
  static Future<File?> openImagePicker() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  static Future<File?> openNativeCamera() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  Future<void> fixExifRotation(String imagePath) async {
    try {
      final originalFile = File(imagePath);
      List<int> imageBytes = await originalFile.readAsBytes();

      final orientation = await NativeDeviceOrientationCommunicator()
          .orientation(useSensor: true);

      final img.Image originalImage = img.decodeImage(imageBytes) as img.Image;
      img.Image fixedImage;
      switch (orientation) {
        case NativeDeviceOrientation.landscapeLeft:
          fixedImage = img.copyRotate(originalImage, -90);
          await originalFile.writeAsBytes(img.encodeJpg(fixedImage));
          break;
        case NativeDeviceOrientation.landscapeRight:
          fixedImage = img.copyRotate(originalImage, 90);
          await originalFile.writeAsBytes(img.encodeJpg(fixedImage));
          break;
        default:
          break;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      print(sourceFile);
      print(newPath);
      print(Directory(
              "/storage/emulated/0/Android/data/com.beauty_fyi/files/SMPictures/")
          .existsSync());
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      try {
        final newFile = await sourceFile.copy(newPath);
        await sourceFile.delete();
        // print(newFile);
        return newFile;
      } catch (e) {
        print(e);
        throw e;
      }
    }
  }

  Future<Directory> getDirectory() async {
    if (Platform.isAndroid) {
      if (await getExternalStorageDirectory() != null)
        return await getExternalStorageDirectory() as Directory;
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}
