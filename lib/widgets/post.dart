import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/error.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final Map<String, bool> likes;

  const Post({
    Key key,
    @required this.postId,
    @required this.ownerId,
    @required this.username,
    @required this.location,
    @required this.description,
    @required this.mediaUrl,
    @required this.likes,
  }) : super(key: key);

  int get likeCount {
    int count = 0;
    if (likes == null) return count;
    likes.values.forEach((val) {
      if (val) count++;
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        this.postId,
        this.ownerId,
        this.username,
        this.location,
        this.description,
        this.mediaUrl,
        this.likes,
        this.likeCount,
      );

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'] == null
          ? {}
          : (doc['likes'] as Map<String, dynamic>).map((key, value) {
              return MapEntry<String, bool>(key, value as bool);
            }),
    );
  }
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map<String, bool> likes;
  int likeCount = 0;
  bool isLiked = false;
  bool _showHeart = false;

  _PostState(this.postId, this.ownerId, this.username, this.location,
      this.description, this.mediaUrl, this.likes, this.likeCount);

  @override
  Widget build(BuildContext context) {
    isLiked = likes[currentUserId] == true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  Widget buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        } else {
          if (snapshot.hasError) {
            return ErrorDisplay(
                title: 'Error Encountered', message: snapshot.error.toString());
          } else {
            User user = User.fromDocument(snapshot.data);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: GestureDetector(
                onTap: () {},
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: Text(
                location,
              ),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert),
              ),
            );
          }
        }
      },
    );
  }

  Widget buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          _showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: .4, end: 1.6),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                        scale: anim.value,
                        child: Icon(
                          Icons.favorite,
                          size: 80.0,
                          color: Colors.red,
                        ),
                      ))
              : Text(''),
        ],
      ),
    );
  }

  Widget buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '${likeCount} likes',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '${username}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                description,
              ),
            )
          ],
        ),
      ],
    );
  }

  void handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});

      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        _showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          _showHeart = false;
        });
      });
    }
  }
}
