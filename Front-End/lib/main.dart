import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:useful/app.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(UsefulApp());
  if (kIsWeb) {
    debugPrint("Using latest Chrome to get best experience!");
  } else if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
