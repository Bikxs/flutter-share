import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: 'Set up your profile',
        isAppTitle: false,
        removeBackButton: true,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    'Create a username',
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                    autovalidate: true,
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: 'Must be at least 3 characters'),
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return 'Username too short';
                        } else if (val.trim().length > 12) {
                          return 'User name too long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        username = value;
                      },
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Center(
                    child: Text(
                      'submit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final snackBar = SnackBar(
        content: Text('Welcome $username'),
        backgroundColor: Colors.green,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }
}
