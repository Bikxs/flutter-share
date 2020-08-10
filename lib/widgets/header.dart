import 'package:flutter/material.dart';

AppBar header(BuildContext context, {isAppTitle = true, String titleText}) {
  return AppBar(
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
