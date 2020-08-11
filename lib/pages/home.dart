import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final postRef = Firestore.instance.collection('posts');
final StorageReference storageRef = FirebaseStorage.instance.ref();

final DateTime timeStamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    // detects when uer has signed in or out
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      handeSignIn(account);
    }, onError: (err) {
      print('Error signing in $err');
    });
    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((GoogleSignInAccount account) {
      handeSignIn(account);
    }).catchError((err) {
      print('Error signing in $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  void login() {
    googleSignIn.signIn();
  }

  void logout() {
    googleSignIn.signOut();
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void handeSignIn(GoogleSignInAccount account) {
    if (account != null) {
//      print(account);
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  void onTapTabBar(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  Future<void> createUserInFirestore() async {
    //check if user exists in firestore collection
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    //if user doest exits, then take them to create account page
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      // get username from create account, use it to make a new doc in users collection

      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timeStamp.toIso8601String(),
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print('currentUser.email: ${currentUser.email}');
  }

  Widget buildAuthScreen() => Scaffold(
        body: PageView(
          children: <Widget>[
            Timeline(
              logout: logout,
            ),
            ActivityFeed(),
            Upload(currentUser: currentUser),
            Search(),
            Profile(profileId: currentUser?.id),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTapTabBar,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
            BottomNavigationBarItem(
                icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            )),
            BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ],
        ),
      );

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                login();
              },
              child: Container(
                width: 260,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
