import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:zerosix_ta/admin/admin.dart';
import 'package:zerosix_ta/register.dart';
import 'package:zerosix_ta/user/user.dart';

import 'Route/faderoute.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseApp app = await Firebase.initializeApp();
  FirebaseStorage storage = FirebaseStorage(
      app: app, storageBucket: 'gs://zerosix-ta-b5b14.appspot.com/');
  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  MyApp({this.storage});
  final FirebaseStorage storage;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        storage: storage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final FirebaseStorage storage;

  MyHomePage({Key key, this.title, this.storage}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signInWithEmailAndPassword() async {
    try {
      var res = await _auth.signInWithEmailAndPassword(
        email: username.text,
        password: password.text,
      );
      print(res);

      final User user = (res).user;
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(user.email + " signed in."),
      ));

      Navigator.pushReplacement(
          context,
          FadeRoute(
              page: UserHomePage(storage: widget.storage, uid: user.uid)));
    } catch (e) {
      print(e);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to sign in with Email & Password"),
      ));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 20.0, left: 20, right: 20, top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 35,
                        color: Colors.black87,
                        letterSpacing: 3,
                      ),
                    ),
                    Text("Please login to your account to continue.",
                        style: TextStyle(fontSize: 15, color: Colors.black54)),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15, bottom: 10, top: 10),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: username,
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Please enter some text';
                                return null;
                              },
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                  labelText: "Email Address"),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: password,
                              validator: (String value) {
                                if (value.isEmpty)
                                  return 'Please enter some text';
                                return null;
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                          border: Border.all(
                              width: 2.0, color: Colors.orange.shade300),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              offset: new Offset(2.0, 0),
                            )
                          ]),
                      child: FlatButton(
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          if (username.text == "admin" &&
                              password.text == "admin") {
                            Navigator.pushReplacement(
                                context,
                                FadeRoute(
                                    page: AdminHomePage(
                                        storage: widget.storage)));
                          } else if (username.text != "admin" &&
                              username.text != null) {
                            if (_formKey.currentState.validate()) {
                              _signInWithEmailAndPassword();
                            }
                          }
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                          border: Border.all(
                              width: 2.0, color: Colors.orange.shade300),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              offset: new Offset(2.0, 0),
                            )
                          ]),
                      child: FlatButton(
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          Navigator.push(
                              context, FadeRoute(page: RegisterPage()));
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(color: Colors.orange, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
