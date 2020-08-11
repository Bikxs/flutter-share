import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/error.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController _searchController = TextEditingController();

  void _handleSearch(String query) {
    print('searching $query');
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  Widget buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        } else {
          if (snapshot.hasError) {
            return ErrorDisplay(
                title: 'User Search Error', message: snapshot.error.toString());
          } else {
            List<UserResult> searchResults = [];
            snapshot.data.documents.forEach((doc) {
              User user = User.fromDocument(doc);
              searchResults.add(UserResult(user: user));
            });
            return ListView(
              children: searchResults,
            );
            ;
          }
        }
      },
    );
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ),
        onFieldSubmitted: (value) {
          _handleSearch(value.trim());
        },
      ),
    );
  }

  Widget buildNoContent() {
    final orientation = MediaQuery
        .of(context)
        .orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 60.0),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor
          .withOpacity(0.8),
      appBar: buildSearchField(),
      body:
      searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .primaryColor
          .withOpacity(.7),
      child: Column(children: [
        GestureDetector(
          onTap: () {
            print('tapped');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: Text(user.displayName, style: TextStyle(color: Colors
                .white, fontWeight: FontWeight.bold),),
            subtitle: Text(user.username, style: TextStyle(color: Colors
                .white),),
          ),
        ),
        Divider(height: 2.0,color: Colors.white54),
      ],),
    );
  }
}
