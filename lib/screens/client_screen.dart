import 'dart:async';
import 'dart:io';

import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/providers/clients_provider.dart';
import 'package:beauty_fyi/providers/scroll_provider.dart';
import 'package:beauty_fyi/providers/sessions_provider.dart';
import 'package:beauty_fyi/container/app_bar/app_bar.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/session_model.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/rendering.dart';

final scrollNotifierProvider =
    StateNotifierProvider<ScrollNotifier, ScrollState>(
        (ref) => ScrollNotifier());
final clientNotifierProvider =
    StateNotifierProvider.family<ClientsNotifier, ClientsState, int>(
        (ref, params) => ClientsNotifier(ClientProviderEnums.READONE, params));
final sessionNotifierProvider =
    StateNotifierProvider.family<SessionsNotifier, SessionsState, int>(
        (ref, params) =>
            SessionsNotifier(SessionProviderEnums.READBUNDLE, params));

class ClientScreen extends ConsumerWidget {
  final args;
  ClientScreen({this.args});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(clientNotifierProvider(args['id']));
    final scrollState = watch(scrollNotifierProvider);
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: CustomAppBar(
            focused: true,
            transparent: false,
            elevation: scrollState is ScrollInit ? scrollState.elevation : 0,
            dark: false,
            titleText: state is ClientLoaded
                ? "${state.client.clientFirstName} ${state.client.clientLastName}"
                : "",
            centerTitle: true,
            leftIcon: Icons.arrow_back,
                       showMenuIcon: false,

            leftIconClicked: () {
              Navigator.pop(context);
            },
            automaticallyImplyLeading: false),
        body: Container(
          child: SingleChildScrollView(
              controller: context
                  .read(scrollNotifierProvider.notifier)
                  .scrollController,
              physics: ScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _clientScreenHeader(context: context, state: state),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  Text(
                    state is ClientLoaded
                        ? "${state.client.clientFirstName} ${state.client.clientLastName}"
                        : "",
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
                          _clientScreenAnalytics(
                              context: context, state: state),
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
                          _ClientSessions(args['id']),
                          SizedBox(
                            height: 500,
                          )
                        ],
                      )),
                ],
              )),
        ));
  }
}

Widget _clientScreenHeader(
    {required BuildContext context, required ClientsState state}) {
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
                child: state is ClientsLoading
                    ? CircularProgressIndicator()
                    : state is ClientLoaded
                        ? CircleAvatar(
                            radius: MediaQuery.of(context).size.height / 9,
                            backgroundColor: colorStyles['blue'],
                            backgroundImage:
                                File(state.client.clientImage!.path)
                                        .existsSync()
                                    ? FileImage(state.client.clientImage!)
                                    : null)
                        : Container(),
              ))),
    ],
  );
}

Widget _clientScreenAnalytics(
    {required BuildContext context, required ClientsState state}) {
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

class _ClientSessions extends ConsumerWidget {
  final int clientId;
  _ClientSessions(this.clientId);
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(sessionNotifierProvider(clientId));
    return state is SessionsInitial
        ? Container()
        : state is SessionsLoading
            ? Center(child: CircularProgressIndicator())
            : state is SessionBundleLoaded
                ? state.sessionBundle.sessionModel.isEmpty
                    ? Center(
                        child: Text("This user has no sessions"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            ((state.sessionBundle.sessionModel.length) / 3)
                                .ceil(),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Row(children: [
                            _sessionCard(
                                context: context,
                                sessionData: state.sessionBundle.sessionModel,
                                serviceModelData:
                                    state.sessionBundle.serviceModel,
                                serviceMediaData:
                                    state.sessionBundle.serviceMedia,
                                index: index * 3),
                            _sessionCard(
                                context: context,
                                sessionData: state.sessionBundle.sessionModel,
                                serviceModelData:
                                    state.sessionBundle.serviceModel,
                                serviceMediaData:
                                    state.sessionBundle.serviceMedia,
                                index: (index * 3) + 1),
                            _sessionCard(
                                context: context,
                                sessionData: state.sessionBundle.sessionModel,
                                serviceModelData:
                                    state.sessionBundle.serviceModel,
                                serviceMediaData:
                                    state.sessionBundle.serviceMedia,
                                index: (index * 3) + 2),
                          ]);
                        },
                      )
                : state is SessionsError
                    ? Center(child: Text("${state.message}"))
                    : Container();
  }
}

Widget _sessionCard(
    {required BuildContext context,
    required List<SessionModel> sessionData,
    required List<ServiceModel> serviceModelData,
    required List<List<ServiceMedia>> serviceMediaData,
    required int index}) {
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
  final String serviceName = serviceModelData[index].serviceName ?? "";
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, "/gallery-screen",
            arguments: {"media": serviceMediaData[index]}),
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
                  dateFormat.format(sessionData[index].dateTime as DateTime),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  serviceName,
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
  _ImageSqaure({this.imageFile});
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
