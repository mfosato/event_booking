import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zerosix_ta/Route/faderoute.dart';
import 'package:zerosix_ta/admin/form.dart';
import 'package:zerosix_ta/view/view_event.dart';

import '../main.dart';

class EventAdmin extends StatefulWidget {
  final FirebaseStorage storage;
  EventAdmin({this.storage});

  @override
  _EventAdminPageState createState() => _EventAdminPageState();
}

class _EventAdminPageState extends State<EventAdmin> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  Stream collectionStream =
      FirebaseFirestore.instance.collection('event_list').snapshots();
  CollectionReference users =
      FirebaseFirestore.instance.collection('event_list');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: collectionStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.data == null || snapshot.data.size == 0) {
              return Center(
                  child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add events now!",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
                  ),
                ),
              ));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40.0, left: 20, right: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All events",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: new ListView(
                    primary: false,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                FadeRoute(
                                    page: ViewEvent(
                                  tag: "0",
                                  storage: widget.storage,
                                  id: document.id,
                                  name: document.data()['event'],
                                  description: document.data()['description'],
                                  image: document.data()['imageURL'],
                                  imageName: document.data()['image'],
                                  location: document.data()['location'],
                                  duration: document.data()['duration'],
                                  datetime: document.data()['datetime'],
                                )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              height: 300,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    new BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 10.0,
                                      offset: new Offset(1.0, 0),
                                    )
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: CachedNetworkImage(
                                      height: 170,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                      imageUrl: document.data()['imageURL'],
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Container(
                                        height: 170,
                                        child: Center(
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            document.data()['event'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            document.data()['description'],
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                FadeRoute(
                    page: FormAdmin(storage: widget.storage, action: "add")));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.orange.shade300,
        ),
      ),
    );
  }
}
