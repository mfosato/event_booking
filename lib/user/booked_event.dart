import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zerosix_ta/Route/faderoute.dart';
import 'package:zerosix_ta/user/user.dart';
import 'package:zerosix_ta/view/view_event.dart';

import '../main.dart';

class BookedEvents extends StatefulWidget {
  final FirebaseStorage storage;
  String uid;
  BookedEvents({this.storage, this.uid});

  @override
  _BookedEventsState createState() => _BookedEventsState();
}

class _BookedEventsState extends State<BookedEvents> {
  int _selectedIndex = 1;
  Uint8List imageBytes;
  String errorMsg;

  void _onItemTapped(int index) {
    _selectedIndex = index;
    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
          context,
          FadeRoute(
              page: UserHomePage(
            storage: widget.storage,
            uid: widget.uid,
          )));
    } else if (_selectedIndex == 2) {
      Navigator.pushReplacement(context, FadeRoute(page: MyHomePage()));
    }
  }

  Future getImageFirebase() async {
    FirebaseApp app = await Firebase.initializeApp();
    FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://zerosix-ta-b5b14.appspot.com/');
    storage
        .ref()
        .child("featured_image.jpg")
        .getData(10000000)
        .then((data) => imageBytes = data)
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    getImageFirebase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("UID:" + widget.uid.toString());
    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('booked')
        .snapshots();

    var imgPlaceholder = imageBytes != null
        ? Container(
            color: Colors.black,
            child: Opacity(
              opacity: 0.8,
              child: Container(
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 1,
            child: Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator())));

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
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.899,
                          child: imgPlaceholder),
                      imageBytes != null
                          ? Center(
                              child: Column(
                              children: [
                                Text(
                                  "Book your events now!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      height: 0.9,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "you have no booked events at the moment",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ))
                          : Container()
                    ],
                  ),
                ],
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              print(snapshot.data.size);
              return Center(
                child: Container(
                    height: 50, width: 50, child: CircularProgressIndicator()),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 40),
                  child: Text(
                    "My Booked Events",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 10,
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
                                  uid: widget.uid,
                                  tag: "2",
                                  storage: widget.storage,
                                  id: document.id,
                                  name: document.data()['event'],
                                  description: document.data()['description'],
                                  imageName: document.data()['image'],
                                  image: document.data()['imageURL'],
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
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: "My Events",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: "Log out",
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
