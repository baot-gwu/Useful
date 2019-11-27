import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:useful/colors.dart';
import 'dart:async';
import 'package:useful/utils.dart';
import 'package:useful/app.dart';

class BootUpPage extends StatefulWidget {
  @override
  _BootUpPageState createState() => new _BootUpPageState();
}

class _BootUpPageState extends State<BootUpPage> {
  int count = 0;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gwuBlue,
      body: Center(
        child: Container(
          child: Image.asset('assets/slash.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initFunction();
    _timer = new Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      if (count <= 0) {
        _timer.cancel();
//        debugPrint(MediaQuery.of(context).size.toString());
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        count--;
      }
    });
  }

  void initFunction() async {
    await setGlobalUserInfo(context);
//    debugPrint('Info: initState $globalUserToken');
    await updateUserInfo(globalUserToken, context);
    await getForumList();
  }


}
