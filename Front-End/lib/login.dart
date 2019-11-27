import 'dart:convert' show json;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:useful/app.dart';
import 'package:useful/colors.dart';
import 'package:useful/register.dart';
import 'package:useful/reset_password.dart';
import 'package:useful/utils.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginBodyState extends State<LoginBody> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode passwordNode = FocusNode();

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
          AccentColorOverride(
            color: gwuBlue,
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(passwordNode),
            ),
          ),
          SizedBox(height: 12.0),
          AccentColorOverride(
            color: gwuBlue,
            child: TextField(
              focusNode: passwordNode,
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              onSubmitted: (text) {
                _loginSubmit(context);
              },
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity, // match_parent
            child: RaisedButton(
              child: Text('Login'),
              onPressed: () {
                _loginSubmit(context);
                //Navigator.pop(context);
              },
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text('No account?'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new RegisterPage()));
                },
              ),
              Expanded(
                child: Text(''),
              ),
              FlatButton(
                child: Text('Forget password?'),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new PasswordPage()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _loginSubmit(context) {
    if (_usernameController.text == '' || _passwordController.text == '') {
      final snackBar = SnackBar(
        content: Text('Please input the username and password'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      final snackBarLoginIn = SnackBar(
        content: Text('Loggin in...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarLoginIn);
      http
          .post(loginApi,
              headers: {
                'Authorization':
                    'Basic ZGV2LmJhb3ppaWkudXNlZnVsOnNlY3JldGZvcnVzZWZ1bGJhb3ppaWlkZXY=',
                'Content-Type': 'application/x-www-form-urlencoded'
              },
              body:
                  ("username=${_usernameController.text}&password=${_passwordController.text}&grant_type=password"))
          .then((response) {
        debugPrint("Response: \n ${response.statusCode}\n${response.body}");
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          getMyInfo(data['access_token']);

        } else {
          if (response.statusCode == 400) {
            final snackBar = SnackBar(
                content: Text('Please check your username and password'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          } else if (!httpCodes.contains(response.statusCode)) {
            final snackBar = SnackBar(
              content: Text(
                  'Please check your network connection and try again later'),
              backgroundColor: gwuBlue,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: gwuFlax,
                onPressed: () {},
              ),
            );

            Scaffold.of(context).showSnackBar(snackBar);
          } else {
            final Map<String, dynamic> data = json.decode(response.body);
            final snackBar = SnackBar(
                content: Text('${data['msg']}'),
                backgroundColor: gwuBlue,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: gwuFlax,
                  onPressed: () {},
                ));

            Scaffold.of(context).showSnackBar(snackBar);
          }
        }
      }).catchError((error) {
        final snackBar = SnackBar(
          content:
              Text('Please check your network connection and try again later'),
          backgroundColor: gwuBlue,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: gwuFlax,
            onPressed: () {},
          ),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      });
    }
  }

  void getMyInfo(token) async {
    Map<String, dynamic> data;
    await http.get(getMyInfoApi,
        headers: {'Authorization': 'Bearer $token'}).then((response) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      data = json.decode(response.body);
      if (response.statusCode == 200) {
        _afterDo() async{
          await saveUserInfo(data['data']['id'], data['data']['username'],
              data['data']['email'], data['data']['avatarurl'], token, context);
          await getForumList();
        }
        _afterDo();
      }
    });
    var rng = new Random();
    var welcomeBanners = {
      0: 'Welcome! ${data['data']['username']}',
      1: '${data['data']['username']}, we are waiting for you!',
      2: 'What\'s up! ${data['data']['username']}',
      3: 'We are missing you! ${data['data']['username']}',
      4: '${data['data']['username']}, long time no see!',
    };

    ucBus.fire('login');

    final snackBar = SnackBar(
      content: Text(welcomeBanners[rng.nextInt(welcomeBanners.length)]),
      backgroundColor: gwuBlue,
    );

    Scaffold.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((SnackBarClosedReason reason) {

      Navigator.pop(context);
    }).catchError((error) {
      final snackBar = SnackBar(
        content:
            Text('Please check your network connection and try again later'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(
            Theme.of(context).platform == TargetPlatform.iOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Login'),
      ),
      body: new LoginBody(),
    );
  }
}
