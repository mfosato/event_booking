import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FormAdmin extends StatefulWidget {
  final FirebaseStorage storage;
  String id;
  String action;
  String name;
  String description;
  String location;
  String image;
  String imageName;
  String duration;
  String datetime;
  FormAdmin(
      {this.storage,
      this.id,
      this.action,
      this.name,
      this.imageName,
      this.description,
      this.image,
      this.duration,
      this.datetime,
      this.location});

  @override
  _FormState createState() => _FormState();
}

TextEditingController eventName = TextEditingController();
TextEditingController eventDescription = TextEditingController();
TextEditingController eventDuration = TextEditingController();
TextEditingController eventLocation = TextEditingController();

class _FormState extends State<FormAdmin> {
  bool changeImage = false;
  File _image;
  final picker = ImagePicker();
  final format = DateFormat("yyyy-MM-dd HH:mm");
  String datetime = DateTime.now().toString();

  Uint8List imageBytes;
  String errorMsg;
  bool loading = false;

  Future getImage() async {
    changeImage = true;

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void openGallery() async {
    changeImage = true;

    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void retainImage() async {
    changeImage = false;
  }

  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  Future<String> _uploadFile(String eventName, String uuid, File file) async {
    StorageReference ref = widget.storage.ref().child("images/$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    print(url);

    return url;
  }

  Future<String> _updateFile(String eventName, String uuid) async {
    StorageReference ref = widget.storage.ref().child("images/$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(_image);

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();

    widget.storage.ref().child("images").child(widget.imageName).delete();
    return url;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.action == "update") {
      eventName.text = widget.name;
      eventDescription.text = widget.description;
      eventDuration.text = widget.duration;
      eventLocation.text = widget.location;
      datetime = widget.datetime;
    }

    return SafeArea(
      child: Scaffold(
          body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(),
        inAsyncCall: loading,
        child: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text("None");
                  break;
                case ConnectionState.waiting:
                  return Text("Wait");
                  break;
                case ConnectionState.active:
                  return Text("Active");
                  break;
                case ConnectionState.done:
                  CollectionReference users =
                      FirebaseFirestore.instance.collection('event_list');

                  Future<void> addEvent(String name, String description,
                      String duration, String location) async {
                    final String uuid = Uuid().v1();
                    await Firebase.initializeApp();
                    var imageURL = await _uploadFile(name, uuid, _image);
                    return users.add({
                      'event': name, // John Doe
                      'description': description,
                      'image': uuid + ".jpg",
                      'imageURL': imageURL,
                      'datetime': datetime,
                      'duration': duration,
                      'location': location
                    }).then((value) {
                      print("user added");
                      setState(() {
                        loading = false;
                      });
                    }).catchError((error) {
                      print("Failed to add user: $error");
                      setState(() {
                        loading = false;
                      });
                    });
                  }
                  Future<void> updateEvent(String name, String description,
                      String duration, String location) async {
                    final String uuid = Uuid().v1();
                    await Firebase.initializeApp();

                    if (changeImage == true) {
                      var imageURL = await _updateFile(name, uuid);

                      return users.doc(widget.id).update({
                        'event': name, // John Doe
                        'description': description,
                        "image": "$uuid.jpg",
                        "imageURL": imageURL,
                        'datetime': datetime,
                        'duration': duration,
                        'location': location
                      }).then((value) {
                        print("Updated Event and image");
                      }).catchError(
                          (error) => print("Failed to add user: $error"));
                    } else {
                      return users.doc(widget.id).update({
                        'event': name, // John Doe
                        'description': description,
                        'datetime': datetime,
                        'duration': duration,
                        'location': location
                      }).then((value) {
                        print("Updated Event");
                      }).catchError(
                          (error) => print("Failed to add user: $error"));
                    }
                  }
                  return ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          Container(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            widget.action.toUpperCase() +
                                                " event",
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      height: 55,
                                      child: TextFormField(
                                        controller: eventName,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.celebration),
                                            border: OutlineInputBorder(),
                                            labelText: "Event Name"),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                        height: 100,
                                        child: TextFormField(
                                          controller: eventDescription,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                              prefixIcon:
                                                  Icon(Icons.celebration),
                                              border: OutlineInputBorder(),
                                              labelText: "Event Desccription"),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 200,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          widget.action == "add"
                                              ? _image == null
                                                  ? Text('No image selected.')
                                                  : Image.file(
                                                      _image,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                    )
                                              : changeImage == false
                                                  ? CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                      imageUrl: widget.image,
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Center(
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    )
                                                  : _image == null
                                                      ? Text(
                                                          'No image selected.')
                                                      : Image.file(
                                                          _image,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                        ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              RaisedButton(
                                                color: Colors.orange.shade100,
                                                onPressed: openGallery,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text("Gallery",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ),
                                              ),
                                              RaisedButton(
                                                color: Colors.orange.shade100,
                                                onPressed: getImage,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text("Camera",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.action == "add"
                                                    ? false
                                                    : true,
                                                child: RaisedButton(
                                                  color: Colors.orange.shade100,
                                                  onPressed: retainImage,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text("Retain",
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 60,
                                      child: DateTimeField(
                                        format: format,
                                        initialValue:
                                            datetime != null || datetime != ""
                                                ? DateTime.parse(datetime)
                                                : DateTime.now(),
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.date_range),
                                            border: OutlineInputBorder(),
                                            labelText:
                                                "Date and Time of event"),
                                        onShowPicker:
                                            (context, currentValue) async {
                                          final date = await showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2100));
                                          if (date != null) {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                      currentValue ??
                                                          DateTime.now()),
                                            );
                                            datetime = DateTimeField.combine(
                                                    date, time)
                                                .toString();

                                            return DateTimeField.combine(
                                                date, time);
                                          } else {
                                            return currentValue;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                      height: 55,
                                      child: TextFormField(
                                        controller: eventDuration,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.timelapse),
                                            border: OutlineInputBorder(),
                                            labelText: "Event Duration"),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                      height: 55,
                                      child: TextFormField(
                                        controller: eventLocation,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.map),
                                            border: OutlineInputBorder(),
                                            labelText: "Event Location"),
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Container(
                                      width: 200,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.orange.shade400,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(40),
                                          ),
                                          border: Border.all(
                                              width: 2.0,
                                              color: Colors.orange.shade300),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 5.0,
                                              offset: new Offset(2.0, 0),
                                            )
                                          ]),
                                      child: FlatButton(
                                        onPressed: () async {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          if (widget.action == "add") {
                                            addEvent(
                                                eventName.text,
                                                eventDescription.text,
                                                eventDuration.text,
                                                eventLocation.text);
                                          } else if (widget.action ==
                                              "update") {
                                            updateEvent(
                                                eventName.text,
                                                eventDescription.text,
                                                eventDuration.text,
                                                eventLocation.text);
                                            Navigator.pop(context);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ]))),
                        ],
                      ),
                    ],
                  );
                  break;
              }
            }),
      )),
    );
  }
}
