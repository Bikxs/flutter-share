import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final bool allowSendReport;

  const ErrorDisplay(
      {@required this.title,
      @required this.message,
      this.allowSendReport = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.redAccent,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.error,
              color: Colors.white,
              size: 48,
            ),
            title: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message,
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Spacer(),
          if (allowSendReport)
            Container(

              decoration: BoxDecoration(border: Border.all(color: Colors.white)),
              alignment: Alignment.bottomRight,
              child: FlatButton.icon(
                onPressed: () {
                  print('Error Title:$title\nError Message: $message');
                },
                icon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                label: Text(
                  'Send Report',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
        ],
      ),
    );
    ;
  }
}
