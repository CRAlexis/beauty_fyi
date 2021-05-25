import 'package:beauty_fyi/container/media/grid_media.dart';
import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class TabCard extends StatefulWidget {
  final String serviceDescription;
  final int serviceId;

  const TabCard(
      {Key? key, required this.serviceDescription, required this.serviceId})
      : super(key: key);
  @override
  _TabCardState createState() => _TabCardState();
}

class _TabCardState extends State<TabCard> with SingleTickerProviderStateMixin {
  TabController? tabController;
  late final Future<List<ServiceMedia>> images;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    images = fetchImages(serviceId: widget.serviceId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        child: TabBar(
            controller: tabController,
            labelColor: Colors.black,
            indicatorColor: colorStyles['green'],
            tabs: [
              Tab(
                text: "Description",
              ),
              Tab(
                text: "Analytics",
              ),
              Tab(
                text: "Media",
              ),
            ]),
      ),
      Container(
        height: 200,
        child: TabBarView(controller: tabController, children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Container(
                child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(widget.serviceDescription)
                      ],
                    ))),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Coming soon...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          GridMedia(images: images)
        ]),
      ),
    ]);
  }
}

Future<List<ServiceMedia>> fetchImages({required int serviceId}) async {
  return await ServiceMedia()
      .readServiceMedia(sql: "service_id = ?", args: [serviceId]);
}
