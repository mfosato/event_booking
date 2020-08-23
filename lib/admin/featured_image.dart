import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zerosix_ta/Route/faderoute.dart';

import '../main.dart';

class FeaturedImage extends StatefulWidget {
  final FirebaseStorage storage;
  FeaturedImage({
    this.storage,
  });

  @override
  _FeaturedImageState createState() => _FeaturedImageState();
}

class _FeaturedImageState extends State<FeaturedImage> {
  bool changeImage = false;
  File _image;
  final picker = ImagePicker();
  Uint8List imageBytes;
  String errorMsg;

  Future getImage() async {
    setState(() {
      changeImage = true;
    });
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

    getImageFirebase();
  }

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

  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  Future<void> _uploadFile() async {
    widget.storage.ref().child("featured_image.jpg").delete();
    final StorageReference ref =
        widget.storage.ref().child('feature_image.jpg');
    final StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    setState(() {
      _tasks.add(uploadTask);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImageFirebase();
  }

  @override
  Widget build(BuildContext context) {
    var img = imageBytes != null
        ? Image.memory(
            imageBytes,
            fit: BoxFit.cover,
          )
        : Text(errorMsg != null ? errorMsg : "Loading...");

    return SafeArea(
      child: Scaffold(
          body: FutureBuilder(
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
                    return ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: [
                        Column(
                          children: [
                            Container(
                                child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Featured Image",
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        child: Column(
                                          children: [
                                            changeImage == false
                                                ? img
                                                : _image == null
                                                    ? Text('No image selected.')
                                                    : Image.file(_image),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                RaisedButton(
                                                  color: Colors.orange.shade100,
                                                  onPressed: openGallery,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text("Camera",
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                  ),
                                                ),
                                                RaisedButton(
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
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: RaisedButton(
                                          color: Colors.orange.shade200,
                                          onPressed: () {
                                            _uploadFile();
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text("Submit",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        ),
                                      )
                                    ]))),
                          ],
                        ),
                      ],
                    );
                    break;
                }
              })),
    );
  }
}
