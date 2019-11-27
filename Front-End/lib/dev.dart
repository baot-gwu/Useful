import 'package:flutter/material.dart';
import 'package:useful/forum_list.dart';
import 'package:useful/useful_drawer.dart';
import 'package:useful/bootup.dart';
import 'package:useful/colors.dart';
import 'package:useful/login.dart';
import 'package:useful/profile.dart';
import 'package:useful/register.dart';
import 'package:useful/reset_password.dart';
//import 'package:useful/app.dart';

class DevPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      navigatorKey: navigatorKey,
      title: 'USEFUL dev',
      home: Scaffold(
        appBar: AppBar(
          title: Text('dev Tool'),
        ),
        drawer: new UsefulDrawer(),
        body: Center(
          child: ListView(children: <Widget>[
            Center(
              child: Text('Route Center'),
            ),
            Divider(),
            Center(
              child: Text('User Center'),
            ),
            RaisedButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new LoginPage()));
//                Navigator.pushNamed(context, '/login');
              },
            ),
            RaisedButton(
              child: Text('Resgister'),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new RegisterPage()));
              },
            ),
            RaisedButton(
              child: Text('Reset Password'),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new PasswordPage()));
              },
            ),
            RaisedButton(
                child: Text('Profiles'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ProfilePage()));
//                  Navigator.pushNamed(context, '/profile');
                }),
            Divider(),
            Center(
              child: Text('Forum'),
            ),
            RaisedButton(
                child: Text('ForumList'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ForumListPage()));
//                  Navigator.pushNamed(context, '/player');
                }),
            Divider(),
            Center(
              child: Text('Other'),
            ),
            RaisedButton(
              child: Text('Bootup'),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new BootUpPage()));
              },
            ),
          ]),
        ),
      ),
      theme: usefulTheme,
    );
  }
}
