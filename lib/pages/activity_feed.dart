import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isAppTitle: false,titleText: 'Activity Feed'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Activity Feed',style: TextStyle(fontSize: 24),),
      ),
    );

  }
}

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Activity Feed Item');
  }
}
