import 'package:flutter/material.dart';
import 'package:useful/register.dart';
import 'dart:async';
import 'package:useful/useful_drawer.dart';
import 'package:useful/utils.dart';
import 'package:useful/login.dart';
import 'package:useful/app.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Useful!'),
      ),
      drawer: new UsefulDrawer(),
      body: new HomeBody(),
    );
  }
}

class _HomeBodyState extends State<HomeBody> {
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 40.0),
            Column(
              children: <Widget>[
                Image.asset('assets/useful_logo_trans.png'),
                SizedBox(height: 16.0),
              ],
            ),
            SizedBox(height: 40.0),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text('Login'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new LoginPage()));
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text('Register'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new RegisterPage()));
                },
              ),
            ),
          ]),
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(const Duration(seconds: 5), (timer) {
      if (globalUserToken != null) {
        setState(() {});
        _timer.cancel();
      }
    });
    ucBus.on().listen((event) {
      debugPrint(event.toString());
      if (event == 'login' || event == 'logout')
        setState(() {

        });
    });
    initFunction();
  }

  void initFunction() async {
    _timer = _timer;
    await setGlobalUserInfo(context);
//    debugPrint('Info: initState $globalUserToken');
    await updateUserInfo(globalUserToken, context);
  }
}
