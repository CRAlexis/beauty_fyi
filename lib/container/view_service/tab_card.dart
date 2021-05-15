import 'package:beauty_fyi/styles/colors.dart';
import 'package:flutter/material.dart';

class TabCard extends StatefulWidget {
  final String serviceDescription;
  final int serviceId;

  const TabCard({Key key, this.serviceDescription, this.serviceId})
      : super(key: key);
  @override
  _TabCardState createState() => _TabCardState();
}

class _TabCardState extends State<TabCard> with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        child: Column(children: [
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
              Align(
                alignment: Alignment.center,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Coming soon...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          ),
        ]));
  }
}
