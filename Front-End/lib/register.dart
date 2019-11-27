import 'package:flutter/material.dart';
import 'package:useful/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:useful/app.dart';
import 'package:useful/utils.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        title: Text('Register'),
      ),
      body: new RegisterBody(),
    );
  }
}

class RegisterBody extends StatefulWidget {
  @override
  _RegisterBodyState createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  final FocusNode passwordNode = FocusNode();
  final FocusNode emailNode = FocusNode();

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
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(emailNode),
            ),
          ),
          SizedBox(height: 12.0),
          AccentColorOverride(
            color: gwuBlue,
            child: TextField(
              focusNode: emailNode,
              controller: _emailController,
              obscureText: false,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              onSubmitted: (text) {
                _registerSubmit(context);
              },
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity, // match_parent
            child: RaisedButton(
              child: Text('Register'),
              onPressed: () {
                _registerSubmit(context);
                //Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _registerSubmit(context) {
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
      final snackBarRegister = SnackBar(
        content: Text('Please Wait...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarRegister);
      http
          .post(registerApi,
              headers: {
                'Authorization':
                    'Basic ZGV2LmJhb3ppaWkudXNlZnVsOnNlY3JldGZvcnVzZWZ1bGJhb3ppaWlkZXY=',
                'Content-Type': 'application/json'
              },
              body: json.encode({
                'username': _usernameController.text,
                'password': _passwordController.text,
                'email': _emailController.text,
              }))
          .then((response) {
        debugPrint(
            "Response: \n\tCode: ${response.statusCode} ${(response.statusCode == 200)} ${(!httpCodes.contains(response.statusCode))}\n\tBody: ${response.body}");
        if (response.statusCode == 200) {
          final Map<dynamic, dynamic> data = json.decode(response.body);
          saveUserInfo(
              data['id'],
              data['username'],
              data['email'],
              data['avatarurl'],
              data['authorization']['access_token'],
              context);
          final snackBar = SnackBar(
            content: Text('Welcome to join us, ${data['username']}!'),
            backgroundColor: gwuBlue,
          );

          Scaffold.of(context)
              .showSnackBar(snackBar)
              .closed
              .then((SnackBarClosedReason reason) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          });
        } else if (response.statusCode == 409) {
          final snackBar = SnackBar(
            content: Text('Username or email already exist'),
            backgroundColor: gwuBlue,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: gwuFlax,
              onPressed: () {},
            ),
          );

          Scaffold.of(context).showSnackBar(snackBar);
        } else if (!httpCodes.contains(response.statusCode)) {
          debugPrint("FUCK");
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
      }).catchError((error) {
        debugPrint(error);
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
}
