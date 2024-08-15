import 'package:flutter/material.dart';

class SnackBarMethod
{
  showSnackBarMsg(String msg, BuildContext cxt)
  {
    var sbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(cxt).showSnackBar(sbar);
  }
}