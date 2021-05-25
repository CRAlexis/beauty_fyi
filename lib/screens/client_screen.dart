import 'dart:async';
import 'dart:io';

import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_bundle_model.dart';
import 'package:flutter/services.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/rendering.dart';

class ClientScreen extends StatefulWidget {
  final args;
  ClientScreen({Key? key, this.args}) : super(key: key);
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  Future<List<ServiceMedia>>? images;
  ScrollController _pageScrollController = ScrollController();
  late Future<SessionBundleModel> clientSessions;
  late Timer refreshStateTimer;
  double elevation = 0;
  @override
  void initState() {
    super.initState();
    images = fetchImages(clientId: widget.args['clientId']);
    clientSessions = fetchSessions(clientId: widget.args['clientId']);
    _pageScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _pageScrollController.dispose();
      refreshStateTimer.cancel();
    } catch (e) {}
  }

  _scrollListener() {
    if (_pageScrollController.position.pixels > 50) {
      setState(() {
        elevation = 20;
      });
    } else {
      setState(() {
        elevation = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: CustomAppBar(
            focused: true,
            transparent: false,
            elevation: elevation,
            dark: false,
            titleText:
                "${widget.args['clientFirstName']} ${widget.args['clientLastName']}",
            centerTitle: true,
            leftIcon: Icons.arrow_back,
            rightIcon: null,
            leftIconClicked: () {
              Navigator.pop(context);
            },
            automaticallyImplyLeading: false),
        body: Container(
          child: SingleChildScrollView(
              controller: _pageScrollController,
              physics: ScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _clientScreenHeader(context: context, widget: widget),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  Text(
                    "${widget.args['clientFirstName']} ${widget.args['clientLastName']}",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.black87,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Column(
                        children: [
                          _clientScreenQuickAnalytics(
                              context: context, widget: widget),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 15,
                          ),
                          Text(
                            "Previous sessions",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 60,
                          ),
                          _clientSessionCards(
                              context: context,
                              widget: widget,
                              clientSessions: clientSessions,
                              refreshState: () {
                                setState(() {});
                              }),
                          SizedBox(
                            height: 1000,
                          )
                          /*Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  flex: 1,
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      width:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      decoration: BoxDecoration(
                                          color: colorStyles['green'],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "16.05.2021",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Flat twist service",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              Flexible(
                                  flex: 1,
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      width:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      decoration: BoxDecoration(
                                          color: colorStyles['dark_purple'],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "1.05.2021",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Retwist service",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              Flexible(
                                  flex: 1,
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      width:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      decoration: BoxDecoration(
                                          color: colorStyles['blue'],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "23.04.2021",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Washing service",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          )*/
                        ],
                      )),
                  //list view with rounded cards of previsous sessions, would be photo of the session with white text
                  //IF no photo then maybe just greyed out
                ],
              )),
        ));
  }
}

Widget _clientScreenHeader({required BuildContext context, required widget}) {
  return Stack(
    alignment: Alignment.topCenter,
    children: [
      Container(
        height: MediaQuery.of(context).size.height / 7,
        color: colorStyles['blue'],
      ),
      Container(
          padding: EdgeInsets.only(top: 0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height / 8),
              ),
              elevation: 5,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height / 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height / 9,
                  backgroundColor: colorStyles['blue'],
                  backgroundImage: widget.args['clientImage'].existsSync()
                      ? FileImage(widget.args['clientImage']!)
                      : null,
                ),
              ))),
    ],
  );
}

Widget _clientScreenQuickAnalytics(
    {required BuildContext context, required widget}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Flexible(
          flex: 1,
          child: Column(
            children: [
              Text(
                "7",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "sessions",
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          )),
      Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "95%",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "satisfaction",
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          )),
      Flexible(
          flex: 1,
          child: Column(
            children: [
              Text(
                "£312.50",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "revenue",
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          ))
    ],
  );
}

Widget _clientSessionCards(
    {required BuildContext context,
    required widget,
    required Future<SessionBundleModel> clientSessions,
    refreshState}) {
  Timer timer;

  return FutureBuilder<SessionBundleModel>(
    future: clientSessions,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final SessionBundleModel sessionBundle =
            snapshot.data as SessionBundleModel;
        if (sessionBundle.sessionModel.length == 0) {
          return Text("this user currently has no sessions");
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: ((sessionBundle.sessionModel.length) / 3).ceil(),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final List<SessionModel> sessionData = sessionBundle.sessionModel;
            final List<ServiceModel> serviceData = sessionBundle.serviceModel;
            final List<List<ServiceMedia>> serviceMediaData =
                sessionBundle.serviceMedia;
            return Row(children: [
              _sessionCard(
                  context: context,
                  sessionData: sessionData,
                  serviceModelData: serviceData,
                  serviceMediaData: serviceMediaData,
                  index: index * 3),
              _sessionCard(
                  context: context,
                  sessionData: sessionData,
                  serviceModelData: serviceData,
                  serviceMediaData: serviceMediaData,
                  index: (index * 3) + 1),
              _sessionCard(
                  context: context,
                  sessionData: sessionData,
                  serviceModelData: serviceData,
                  serviceMediaData: serviceMediaData,
                  index: (index * 3) + 2),
            ]);
          },
        );
      } else {
        print("no data found refreshing");
        timer = Timer(Duration(milliseconds: 500), () {
          print("no data found refreshing");
          refreshState();
        });
        timer.cancel();
        return Text("this user currently has no sessions");
      }
    },
  );
}

Future<List<ServiceMedia>> fetchImages({int? clientId}) async {
  return await ServiceMedia()
      .readServiceMedia(sql: "user_id = ?", args: [clientId]);
}

Future<SessionBundleModel> fetchSessions({int? clientId}) async {
  return await SessionModel(
          active: false,
          clientId: clientId,
          currentProcess: null,
          dateTime: DateTime.now(),
          notes: '',
          serviceId: null)
      .readSessions(sql: "client_id = ?", args: [clientId]);
}

Widget _sessionCard(
    {required BuildContext context,
    required List<SessionModel> sessionData,
    required List<ServiceModel> serviceModelData,
    required List<List<ServiceMedia>> serviceMediaData,
    required int index}) {
  print("session length: ${sessionData.length}, index: $index");

  if (sessionData.length <= index) {
    return Container(
      height: MediaQuery.of(context).size.height / 7,
      width: MediaQuery.of(context).size.height / 7,
    );
  }
  final dateFormat = new DateFormat('dd.MM.yyyy');
  final image = serviceMediaData[index]
      .firstWhere((element) => element.fileType == "image",
          orElse: () => ServiceMedia(filePath: ""))
      .filePath as String;
  final String? serviceName = serviceModelData[index].serviceName;
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/gallery-screen",
            arguments: {"sessionModel": sessionData[index]}),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            height: MediaQuery.of(context).size.height / 7,
            width: MediaQuery.of(context).size.height / 7,
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(image)),
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(.9), BlendMode.dstATop),
                ),
                color: image != "" ? Colors.black : colorStyles['green'],
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateFormat.format(sessionData[index].dateTime),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  serviceName != null ? serviceName : "...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ));
  });
}

class _ImageSqaure extends StatelessWidget {
  final File? imageFile;
  final bool? isEnd;
  _ImageSqaure({this.imageFile, this.isEnd});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 82,
        padding: EdgeInsets.only(right: 5),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/full-screen-media",
              arguments: {'file_type': 'image', 'file_path': imageFile}),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: FileImage(imageFile!)),
            ),
          ),
        ));
  }
}

class _VideoSqaure extends StatefulWidget {
  final File? videoFile;
  final bool? isEnd;

  _VideoSqaure({this.videoFile, this.isEnd});

  @override
  __VideoSqaureState createState() => __VideoSqaureState();
}

class __VideoSqaureState extends State<_VideoSqaure> {
  late VideoPlayerController _controller;
  Future<void>? _initialiseVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.videoFile!);
    _initialiseVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialiseVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/full-screen-media",
                        arguments: {
                          'file_type': 'video',
                          'file_path': widget.videoFile
                        }),
                child: Stack(
                  children: [
                    Container(
                        width: 82,
                        padding: EdgeInsets.only(right: 5),
                        child: Container(
                          child: VideoPlayer(_controller),
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.play_arrow,
                            color: Colors.white, size: 10)),
                  ],
                ));
          } else {
            return Container(
              width: 82,
              padding: EdgeInsets.only(right: 2),
            );
          }
        });
  }
}

/*
FutureBuilder<List<ServiceMedia>>(
                      future: images,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.length != 0) {
                          print(snapshot.data);
                          return Container(
                              width: double.infinity,
                              height: 80,
                              color: Colors.white,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return snapshot.data![index].fileType ==
                                            "image"
                                        ? _ImageSqaure(
                                            imageFile: File(snapshot
                                                .data![index].filePath!),
                                            isEnd: false,
                                          )
                                        : _VideoSqaure(
                                            videoFile: File(snapshot
                                                .data![index].filePath!),
                                            isEnd: false,
                                          );
                                  }));
                        } else {
                          refreshStateTimer = Timer(Duration(seconds: 3), () {
                            setState(() {});
                          });
                          refreshStateTimer.cancel();
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color?>(
                                colorStyles['green']),
                          );
                        }
                      }),
                  


return Row(
                                          children: [
                                            snapshot.data.length >
                                                    (index * 4) + 1
                                                ? snapshot.data[(index * 4) + 1]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 1]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 1]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: false),
                                            snapshot.data.length >
                                                    (index * 4) + 2
                                                ? snapshot.data[index]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 2]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 2]
                                                            .filePath),
                                                        isEnd: false,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: false),
                                            snapshot.data.length >
                                                    (index * 4) + 3
                                                ? snapshot.data[index]
                                                            .fileType ==
                                                        "image"
                                                    ? _ImageSqaure(
                                                        imageFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 3]
                                                            .filePath),
                                                        isEnd: true,
                                                      )
                                                    : _VideoSqaure(
                                                        videoFile: File(snapshot
                                                            .data[
                                                                (index * 4) + 3]
                                                            .filePath),
                                                        isEnd: true,
                                                      )
                                                : _PlaceholderSqaure(
                                                    isEnd: true)
                                          ],
                                        );
                                      
          

Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red.shade200),
                      minimumSize: MaterialStateProperty.all(Size(150, 35))),
                  onPressed: () => null,
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.white)),
                      backgroundColor:
                          MaterialStateProperty.all(colorStyles['green']),
                      minimumSize: MaterialStateProperty.all(Size(150, 35))),
                  onPressed: () => null,
                  child: Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),*/
