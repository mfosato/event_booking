import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zerosix_ta/Route/faderoute.dart';
import 'package:zerosix_ta/admin/event.dart';
import 'package:zerosix_ta/admin/featured_image.dart';
import 'package:zerosix_ta/admin/form.dart';
import 'package:zerosix_ta/view/view_event.dart';

import '../main.dart';

class AdminHomePage extends StatefulWidget {
  final FirebaseStorage storage;
  AdminHomePage({this.storage});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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

  @override
  void initState() {
    // TODO: implement initState

    getImageFirebase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var imgPlaceholder = imageBytes != null
        ? ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Container(
              color: Colors.black,
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        : Container(
            color: Colors.orange,
            height: MediaQuery.of(context).size.height * 0.35,
          );
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            primary: false,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Administrator",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w500),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context, FadeRoute(page: MyHomePage()));
                            },
                            child: Icon(Icons.logout)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          FadeRoute(
                              page: FeaturedImage(
                            storage: widget.storage,
                          )));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        imgPlaceholder,
                        Text(
                          "Featured Image",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          FadeRoute(
                              page: EventAdmin(
                            storage: widget.storage,
                          )));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        imgPlaceholder,
                        Text(
                          "Events",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
