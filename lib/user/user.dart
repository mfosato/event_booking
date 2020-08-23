import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zerosix_ta/Route/faderoute.dart';
import 'package:zerosix_ta/user/all_events.dart';
import 'package:zerosix_ta/view/view_event.dart';

import '../main.dart';
import 'booked_event.dart';

class UserHomePage extends StatefulWidget {
  final FirebaseStorage storage;
  String uid;
  UserHomePage({this.storage, this.uid});
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  Uint8List imageBytes;
  String errorMsg;

  Future getImageFirebase() async {
    FirebaseApp app = await Firebase.initializeApp();
    FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://zerosix-ta-b5b14.appspot.com/');
    storage
        .ref()
        .child("featured_image.jpg")
        .getData(10000000)
        .then((data) => setState(() {
              imageBytes = data;
            }))
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
  }

  String url;

  Future getImageFirebaseURL() async {
    FirebaseApp app = await Firebase.initializeApp();
    FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://zerosix-ta-b5b14.appspot.com/');
    url = storage.ref().child("featured_image.jpg").getDownloadURL().toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    getImageFirebaseURL();
    super.initState();
    getImageFirebase();
  }

  Stream collectionStream =
      FirebaseFirestore.instance.collection('event_list').limit(4).snapshots();

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;

    void _onItemTapped(int index) {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.pushReplacement(
            context,
            FadeRoute(
                page: BookedEvents(
              storage: widget.storage,
              uid: widget.uid,
            )));
      } else if (_selectedIndex == 2) {
        Navigator.pushReplacement(context, FadeRoute(page: MyHomePage()));
      }
    }

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
            height: MediaQuery.of(context).size.height * 0.899,
            child: Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator())));

    var img = imageBytes != null
        ? ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50)),
            child: Container(
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
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator())));
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: collectionStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                height:
                                    MediaQuery.of(context).size.height * 0.899,
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
                                        "reserve moments within your fingertips",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
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
                    return CircularProgressIndicator();
                  }

                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: img),
                          imageBytes != null
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(10.0),
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
                                        "reserve moments within your fingertips",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ),
                                ))
                              : Container()
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 40.0, left: 20, right: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Featured Events",
                              style: TextStyle(fontSize: 20),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    FadeRoute(
                                        page: AllEvents(
                                      storage: widget.storage,
                                      uid: widget.uid,
                                    )));
                              },
                              child: Text(
                                "View all",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Container(
                          height: 200,
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification:
                                (OverscrollIndicatorNotification overscroll) {
                              overscroll.disallowGlow();
                              return;
                            },
                            child: new ListView(
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          FadeRoute(
                                              page: ViewEvent(
                                            tag: "1",
                                            storage: widget.storage,
                                            id: document.id,
                                            name: document.data()['event'],
                                            description:
                                                document.data()['description'],
                                            image: document.data()['imageURL'],
                                            imageName: document.data()['image'],
                                            location:
                                                document.data()['location'],
                                            duration:
                                                document.data()['duration'],
                                            datetime:
                                                document.data()['datetime'],
                                          )));
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: 40,
                                              imageUrl:
                                                  document.data()['imageURL'],
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            child: Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.orangeAccent
                                                      .withOpacity(0.7),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text(
                                                      document.data()['event'],
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                ))),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
          currentIndex: 0,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
