import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastMethod
{
  showToastMsg(String msg, BuildContext cxt)
  {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // You can change this to TOP, CENTER, etc.
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

