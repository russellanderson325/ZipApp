import 'package:flutter/material.dart';
import 'package:zip/CustomIcons/custom_icons_icons.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  GoogleButton({this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      elevation: 1.0,
      onPressed: onPressed,
      color: Colors.white,
      splashColor: Colors.black12,
      child: Container(
        width: 225.0,
        height: 40.0,
        child: Row(
          children: <Widget>[
            Icon(CustomIcons.google, color: Colors.red),
            Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text(
                "Sign in with Google",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.none,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  fontFamily: "OpenSans",
                ),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
