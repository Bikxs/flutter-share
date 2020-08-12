import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/error.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({Key key, this.profileId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser.id;
  bool _isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'grid';

  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  Future<void> getProfilePost() async {
    setState(() {
      _isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .document(widget.profileId)
        .collection('userPosts')
//        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      _isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      print('postcount: $postCount');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, titleText: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }

  Widget buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        } else {
          if (snapshot.hasError) {
            return ErrorDisplay(
              title: 'Error Encountered',
              message: snapshot.error.toString(),
            );
          } else {
            User user = User.fromDocument(snapshot.data);
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: widget.profileId,
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildCountColumn('posts', postCount),
                                buildCountColumn('following', 0),
                                buildCountColumn('followers', 0),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [buildProfileButton()],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 12, left: 12),
                    child: Text(
                      user.username,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 4.0, left: 12),
                    child: Text(
                      user.displayName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 2, left: 12),
                    child: Text(
                      user.bio,
                    ),
                  )
                ],
              ),
            );
          }
        }
      },
    );
  }

  Widget buildCountColumn(String label, int count) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildProfileButton() {
    //if view own profile show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
          'Edit Profile', Theme.of(context).primaryColor, editProfile);
    }
    return buildButton('Follow', Colors.redAccent, () {});
  }

  Widget buildButton(String label, Color color, Function function) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 30.0,
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(currentUserId: currentUserId)),
    );
  }

  Widget buildProfilePosts() {
    if (_isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/no_content.svg',
                height: MediaQuery.of(context).size.height * .2,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'No Posts',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles =
          posts.map((post) => GridTile(child: PostTile(post: post))).toList();
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else {
      return Column(
        children: posts,
      );
    }
  }

  void setPostOrientations(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  Widget buildTogglePostOrientation() {
    final primaryColor = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: () => setPostOrientations('grid'),
            icon: Icon(Icons.grid_on,
                color: postOrientation == 'grid' ? primaryColor : Colors.grey)),
        IconButton(
          onPressed: () => setPostOrientations('list'),
          icon: Icon(Icons.list,
              color: postOrientation == 'list' ? primaryColor : Colors.grey),
        ),
      ],
    );
  }
}
