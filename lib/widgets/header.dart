import 'package:flutter/material.dart';

AppBar header(BuildContext context, {isAppTitle = true, String titleText,removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: !removeBackButton,
    title: Text(
      isAppTitle ? 'Flutter Share' : titleText,
      style: TextStyle(
        fontFamily: isAppTitle ? 'Signatra':'',
        fontSize: isAppTitle ? 50.0 : 22.0,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
