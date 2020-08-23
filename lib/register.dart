import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Entrypoint example for registering via Email/Password.
class RegisterPage extends StatefulWidget {
  /// The page title.
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success;
  String _userEmail;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Registration",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password', border: OutlineInputBorder()),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Container(
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
                            if (_formKey.currentState.validate()) {
                              _register();
                            }
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code for registration.
  void _register() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Successfully registered ' + _userEmail),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      });
    } else {
      _success = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration failed'),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }
}
