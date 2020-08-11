import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({Key key, this.currentUserId}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isLoading = false;
  User user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              size: 30,
              color: Colors.green,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: _isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Hero(
                          tag: user.id,
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                              ),
                              TextFormField(
                                controller: _displayNameController,
                                decoration: InputDecoration(
                                    hintText: 'Update display name',
                                    labelText: 'Display Name'),
                                validator: (value) {
                                  if (value.trim().length <= 3) {
                                    return 'Display Name should be atleast 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                              ),
                              TextFormField(
                                controller: _bioController,
                                decoration: InputDecoration(
                                    hintText: 'Update Profile Bio',
                                    labelText: 'Bio'),
                                validator: (value) {
                                  if (value.length > 100) {
                                    return 'Bio is too long, maximum allowed is 100 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfileData,
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Future<void> getUser() async {
    setState(() {
      _isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    _displayNameController.text = user.displayName;
    _bioController.text = user.bio;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateProfileData() async {
    if (_formKey.currentState.validate()) {
      try {
        await usersRef.document(widget.currentUserId).updateData({
          'displayName': _displayNameController.text.trim(),
          'bio': _bioController.text.trim()
        });
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Profile updated',
            ),
          ),
        );
      } catch (error) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Profile update failed:${error.toString()}',
            ),
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
}
