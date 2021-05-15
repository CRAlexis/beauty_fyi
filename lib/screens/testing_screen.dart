import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:social_share/social_share.dart';
import 'package:record/record.dart';

class TestingScreen extends StatefulWidget {
  @override
  _TestingScreenState createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  File _video;
  bool filePicked = false;
  bool isPlaying = false;
  bool fullUpdate = true;

  Future getImage() async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        filePicked = true;
        _video = File(pickedFile.path);
        isPlaying = true;
        fullUpdate = true;
      } else {
        filePicked = false;
        fullUpdate = true;
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 00),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: getImage, child: Text("get video")),
            filePicked
                ? VideoPlayerScreen(
                    videoFile: _video,
                    isPlaying: isPlaying,
                    fullUpdate: fullUpdate)
                : CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Wrap the play or pause in a call to `setState`. This ensures the
              // correct icon is shown.
              setState(() {
                isPlaying = !isPlaying;
                fullUpdate = false;
                // If the video is playing, pause it.
              });
            },
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Icon(
              Icons.wifi,
            ),
          ),
        ],
        // Display the correct icon depending on the state of the player.
      ), //
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;
  final bool isPlaying;
  final bool fullUpdate;
  VideoPlayerScreen({Key key, this.videoFile, this.isPlaying, this.fullUpdate})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initialiseVideoPlayerFuture;
  @override
  void initState() {
    print("#tag Video player controller initialised");
    print("#tag file: ${widget.videoFile.path}");
    _controller = VideoPlayerController.file(widget.videoFile);
    _initialiseVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void didUpdateWidget(VideoPlayerScreen oldWidget) {
    if (widget.fullUpdate) {
      _controller = VideoPlayerController.file(widget.videoFile);
      _initialiseVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      super.didUpdateWidget(oldWidget);
    } else {}
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  /*void convertVideoToAudio() async {
    // var rawFile = await _localFile("raw2.h264");
    var outputfile = await _localFile("output3.mp4");
    final FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
    var rc1 = await flutterFFmpeg.execute(
        "-i ${widget.videoFile.path} -r 40 -filter:v \"setpts=0.25*PTS\" ${outputfile.path}");
    if (rc1 == 0) {
      print("#tag RC1 successfull");
      /*  // var rc2 = await flutterFFmpeg.execute(
          "-fflags +genpts -r 10 -i ${rawFile.path} -c:v copy ${outputfile.path}");
      print("#tag FFmpeg process exited with rc $rc2"); */
      // rawFile.delete(recursive: true);
    }
//  )
    // 
    // 

}*/

  void ffmpegActions() async {
    /* File rawFile = await _localFile("raw2.h264");
    File inputFile = await _localFile("output2.mp4");
    File outputfile = await _localFile("filter_test.mp4");
    File imageFile = await _localFile("beauty-fyi.png");
    File imageOutputFile = await _localFile("watermark.png");
    var info = await executeInfo(File(widget.videoFile.path));
    double duration = double.parse(info.getMediaProperties()['duration']) - 3;
    executeCommand("-i ${inputFile.path} -vf format=gray ${outputfile.path}");*/
  }

  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      _controller.pause();
    } else {
      // If the video is paused, play it.
      _controller.play();
    }
    return FutureBuilder(
        future: _initialiseVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Row(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                bool result = await Record.hasPermission();
                                bool isRecording = await Record.isRecording();
                                if (!result && !isRecording) {
                                  return false;
                                }
                                final p = await getTemporaryDirectory();
                                final String name = DateTime.now()
                                    .toString()
                                    .replaceAll(" ", "");
                                final path = "${p.path}/$name.m4a";

                                var info = await executeInfo(
                                    File(widget.videoFile.path));
                                double duration = double.parse(
                                    info.getMediaProperties()['duration']);
                                int seconds = duration.toInt();
                                int milli =
                                    ((duration - seconds.toDouble()) * 1000)
                                        .toInt();

                                print("#tag seconds: $seconds");
                                print("#tag milli: $milli");
                                var future = new Future.delayed(Duration(
                                    seconds: seconds, milliseconds: milli));
                                await Record.start(
                                  path: path, // required
                                  encoder: AudioEncoder.AAC, // by default
                                  bitRate: 128000, // by default
                                  samplingRate: 44100, // by default
                                );
                                future.then((value) async {
                                  print("#tag timer completed");
                                  await Record.stop();
                                }).then((value) async {
                                  Directory directory =
                                      await getExternalStorageDirectory();
                                  String name = DateTime.now()
                                      .toString()
                                      .replaceAll(" ", "");
                                  String outputPath =
                                      "${directory.path}/$name.mp4";
                                  executeCommand(
                                      // "-i ${widget.videoFile.path} -i $path -vcodec copy -acodec copy -map 0:0 -map 1:0 $outputPath");
                                      "-i ${widget.videoFile.path} -i $path -map 0:0 -map 1:0 -c:v copy -c:a aac -b:a 256k -shortest $outputPath");
                                });
                              },
                              child: Text("Record audio"))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class CameraPreviewTest extends StatefulWidget {
  @override
  _CameraPreviewTestState createState() => _CameraPreviewTestState();
}

class _CameraPreviewTestState extends State<CameraPreviewTest> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  bool isRecording = false;
  String videoPath;
  String videoPathName;

  Future initCamera(
      CameraDescription cameraDescription /*Which camera to show*/) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (cameraController.value.hasError) {
      print('Camera Error ${cameraController.value.errorDescription}');
    }

    try {
      await cameraController.initialize();
    } catch (e) {
      String errorText = 'Error ${e.code} \nError message: ${e.description}';
      print(errorText);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        initCamera(cameras[selectedCameraIndex]).then((value) {});
      } else {
        print('No camera available');
      }
    }).catchError((e) {
      print('Error : ${e.code}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CameraPreviewMine(
                cameraController: cameraController,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: double.infinity,
                padding: EdgeInsets.all(15),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ActionButton(
                      takePhoto: () async {
                        final p = await getTemporaryDirectory();
                        final String name =
                            DateTime.now().toString().replaceAll(" ", "");
                        final path = "${p.path}/$name.png";
                        cameraController.takePicture().then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreviewImageScreen(
                                        mediaPath: path,
                                        fileName: "$name.png",
                                        isImage: true,
                                      )));
                        });
                      },
                    ),
                    RecordButton(
                      buttonClicked: () async {
                        try {
                          final p = await getTemporaryDirectory();
                          final String name =
                              DateTime.now().toString().replaceAll(" ", "");
                          final path = "${p.path}/$name.mp4";

                          if (!isRecording) {
                            videoPathName = name;
                            videoPath = path;
                            print("#tag Started reocording");
                            await cameraController.startVideoRecording();
                            isRecording = true;
                          } else {
                            print("#tag Finished reocording");
                            await cameraController.stopVideoRecording();
                            isRecording = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PreviewImageScreen(
                                        mediaPath: videoPath,
                                        fileName: "$videoPathName.mp4",
                                        isImage: false)));
                          }
                        } catch (e) {
                          print("unable to record: $e");
                        }
                      },
                    ),
                    SwitchCameraButton(switchCamera: () {
                      selectedCameraIndex =
                          selectedCameraIndex < cameras.length - 1
                              ? selectedCameraIndex + 1
                              : 0;
                      CameraDescription selectedCamera =
                          cameras[selectedCameraIndex];
                      initCamera(selectedCamera);
                    })
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CameraPreviewMine extends StatelessWidget {
  final CameraController cameraController;

  const CameraPreviewMine({Key key, this.cameraController}) : super(key: key);

  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Text(
        'Loading',
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      );
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }
}

class ActionButton extends StatefulWidget {
  final VoidCallback takePhoto;
  ActionButton({this.takePhoto});
  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: widget.takePhoto,
            child: Icon(Icons.camera),
          )),
    );
  }
}

class RecordButton extends StatefulWidget {
  final VoidCallback buttonClicked;
  const RecordButton({Key key, this.buttonClicked}) : super(key: key);
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: widget.buttonClicked,
            child: Icon(Icons.camera_roll),
          )),
    );
  }
}

class SwitchCameraButton extends StatelessWidget {
  final VoidCallback switchCamera;
  SwitchCameraButton({Key key, this.switchCamera}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: switchCamera,
            child: Icon(Icons.switch_camera),
          )),
    );
  }
}

class PreviewImageScreen extends StatefulWidget {
  final String mediaPath;
  final String fileName;
  final bool isImage;
  PreviewImageScreen({this.mediaPath, this.fileName, this.isImage});
  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  String editedImage;
  @override
  Widget build(BuildContext context) {
    void shareImage() {
      SocialShare.shareOptions("Share", imagePath: widget.mediaPath);
    }

    return Scaffold(
        body: Container(
            child: widget.isImage
                ? Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Image.file(
                          File(editedImage == null
                              ? widget.mediaPath
                              : editedImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          color: Colors.white,
                          padding: EdgeInsets.all(15),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: ElevatedButton(
                                        onPressed: () => shareImage(),
                                        child: Icon(Icons.share))),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() async {
                                            editedImage = await ffmpegGray(
                                                widget.mediaPath);
                                          });
                                        },
                                        child: Text("Gray"))),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Stack(children: <Widget>[
                    VideoPlayerScreen(
                      fullUpdate: true,
                      videoFile: File(widget.mediaPath),
                      isPlaying: true,
                    ),
                  ])));
  }
}

Future<String> _localPath(int index) async {
  Directory directory;
  switch (index) {
    case 0:
      directory = await getExternalStorageDirectory();
      break;
    case 1:
      directory = await getTemporaryDirectory();
      break;
  }
  return directory.path;
}

Future<File> _localFile(String fileName, int index) async {
  final path = await _localPath(index);
  return File('$path/$fileName');
}

Future<String> ffmpegGray(String inputPath) async {
  File outputPath = await _localFile("edited_image.png", 1);
  print("#tag $inputPath");
  await executeCommand("-y -i $inputPath -vf format=gray ${outputPath.path}");
  return outputPath.path;
}

Future<int> executeCommand(String command) async {
  final FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
  int result = await flutterFFmpeg.execute(command);
  return result;
}

Future<MediaInformation> executeInfo(File file) async {
  final FlutterFFprobe flutterFFprobe = new FlutterFFprobe();
  MediaInformation info = await flutterFFprobe.getMediaInformation(file.path);
  return info;
}
