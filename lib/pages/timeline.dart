import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class Timeline extends StatefulWidget {
  final Function() logout;

  const Timeline({Key key, this.logout}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Timeline',style: TextStyle(fontSize: 24),),
            Center(
              child: RaisedButton.icon(
                onPressed: widget.logout,
                icon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
