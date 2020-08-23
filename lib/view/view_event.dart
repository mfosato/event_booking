import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerosix_ta/Route/faderoute.dart';
import 'package:zerosix_ta/admin/form.dart';

import '../main.dart';

class ViewEvent extends StatefulWidget {
  final FirebaseStorage storage;
  String uid;
  String tag;
  String id;
  String name;
  String description;
  String location;
  String image;
  String imageName;
  String duration;
  String datetime;

  ViewEvent(
      {this.uid,
      this.imageName,
      this.tag,
      this.storage,
      this.id,
      this.name,
      this.description,
      this.image,
      this.duration,
      this.datetime,
      this.location});

  @override
  _ViewEventState createState() => _ViewEventState();
}

Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

class _ViewEventState extends State<ViewEvent> {
  Uint8List imageBytes;
  String errorMsg;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.uid);
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40)),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      imageUrl: widget.image,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: Container(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 20, bottom: 8, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 35,
                                color: Colors.orange,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                  DateFormat()
                                      .format(DateTime.parse(widget.datetime)),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 20, bottom: 8, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timelapse,
                                size: 35,
                                color: Colors.orange,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                  parseDuration(widget.duration).inHours == 1
                                      ? parseDuration(widget.duration)
                                              .inHours
                                              .toString() +
                                          " hour"
                                      : parseDuration(widget.duration).inHours >
                                              1
                                          ? parseDuration(widget.duration)
                                                  .inHours
                                                  .toString() +
                                              " hours"
                                          : parseDuration(widget.duration)
                                                      .inHours ==
                                                  0
                                              ? parseDuration(widget.duration)
                                                      .inMinutes
                                                      .toString() +
                                                  " minutes"
                                              : "",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 20, bottom: 8, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 35,
                                color: Colors.orange,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(widget.location,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.tag == "1" ? true : false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: InkWell(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection('booked')
                            .where('event_id', isEqualTo: widget.id)
                            .get()
                            .then((QuerySnapshot snapshot) {
                          if (snapshot.docs.toString() == "[]") {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('booked')
                                .add({
                                  'event_id': widget.id,
                                  'event': widget.name, // John Doe
                                  'description': widget.description,
                                  'image': widget.imageName,
                                  'datetime': widget.datetime,
                                  'duration': widget.duration,
                                  'location': widget.location,
                                  "imageURL": widget.image
                                })
                                .then((value) => print("Booked Event"))
                                .catchError((error) =>
                                    print("Failed to book event: $error"));
                            Navigator.pop(context);
                          } else {
                            return showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                      title: new Text("Event already booked"),
                                      content: new Text(
                                          "You have already booked this event. You can't book it again."),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ));
                          }
                        });
                      },
                      child: Center(
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 25, bottom: 10, right: 25),
                            child: Center(
                              child: Text("Book",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: widget.tag == "2" ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: InkWell(
                        onTap: () async {
                          await Firebase.initializeApp();
                          CollectionReference users = FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .collection("booked");
                          users
                              .doc(widget.id)
                              .delete()
                              .then((value) => print("Removed Booked Event"))
                              .catchError((error) => print(
                                  "Failed to remove booked event: $error"));
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 25, bottom: 10, right: 25),
                              child: Center(
                                child: Text("Remove Book",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                Visibility(
                    visible: widget.tag == "0" ? true : false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 20, right: 20, bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        FadeRoute(
                                            page: FormAdmin(
                                          id: widget.id,
                                          storage: widget.storage,
                                          action: "update",
                                          name: widget.name,
                                          description: widget.description,
                                          image: widget.image,
                                          imageName: widget.imageName,
                                          datetime: widget.datetime,
                                          duration: widget.duration,
                                          location: widget.location,
                                        )));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade200,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0,
                                          left: 25,
                                          bottom: 10,
                                          right: 25),
                                      child: Center(
                                        child: Text("Edit",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () async {
                                    await Firebase.initializeApp();
                                    CollectionReference users =
                                        FirebaseFirestore.instance
                                            .collection('event_list');
                                    users
                                        .doc(widget.id)
                                        .delete()
                                        .then((value) => print("User Deleted"))
                                        .catchError((error) => print(
                                            "Failed to delete user: $error"));
                                    widget.storage
                                        .ref()
                                        .child("images")
                                        .child(widget.image)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade200,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0,
                                          left: 25,
                                          bottom: 10,
                                          right: 25),
                                      child: Center(
                                        child: Text("Delete",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
