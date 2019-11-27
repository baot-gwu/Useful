import 'package:flutter/material.dart';
import 'package:useful/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:useful/app.dart';

class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
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
        title: Text('Reset Password'),
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
  final _validateCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        children: <Widget>[
          SizedBox(height: 80.0),
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
                onEditingComplete: () {}),
          ),
          SizedBox(height: 12.0),
          Row(
            children: <Widget>[
              Expanded(
                child: AccentColorOverride(
                  color: gwuBlue,
                  child: TextField(
                      controller: _validateCodeController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Validate Code',
                      ),
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(passwordNode);
                      }),
                ),
              ),
              SizedBox(width: 10.0),
              RaisedButton(
                child: Text('Send Email'),
                onPressed: () {
                  _submitEmail(context);
                },
              )
            ],
          ),
          SizedBox(height: 12.0),
          AccentColorOverride(
            color: gwuBlue,
            child: TextField(
              focusNode: passwordNode,
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              onSubmitted: (text) {
                _resetPasswordSubmit(context);
              },
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity, // match_parent
            child: RaisedButton(
              child: Text('Reset Password'),
              onPressed: () {
                _resetPasswordSubmit(context);
                //Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _resetPasswordSubmit(context) {
    if (_usernameController.text == '' ||
        _validateCodeController.text == '' ||
        _passwordController.text == '') {
      final snackBar = SnackBar(
        content:
            Text('Please input the username, validate code and new password'),
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
        content: Text('Please wait...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarLoginIn);
      http
          .post(resetPasswordApi,
              headers: {
                'Authorization':
                    'Basic ZGV2LmJhb3ppaWkudXNlZnVsOnNlY3JldGZvcnVzZWZ1bGJhb3ppaWlkZXY='
              },
              body: json.encode({
                'username': _usernameController.text,
                'code': _validateCodeController.text,
                'password': _passwordController.text
              }))
          .then((response) {
        if (response.statusCode != 200) {
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

          if (data['code'] == 1) {
            final snackBar = SnackBar(
              content: Text("Your password has been reset"),
              backgroundColor: gwuBlue,
            );

            Scaffold.of(context)
                .showSnackBar(snackBar)
                .closed
                .then((SnackBarClosedReason reason) {
              Navigator.pop(context);
            });
          } else {
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

//          debugPrint("Response body: ${response.body}");
        }
      });
    }
  }

  void _submitEmail(context) {
    if (_usernameController.text == '') {
      final snackBar = SnackBar(
        content: Text('Please input the username'),
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
        content: Text('Please wait...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarLoginIn);
      http
          .post(loginApi,
              headers: {
                'Authorization':
                    'Basic ZGV2LmJhb3ppaWkudXNlZnVsOnNlY3JldGZvcnVzZWZ1bGJhb3ppaWlkZXY='
              },
              body: json.encode({
                'username': _usernameController.text,
              }))
          .then((response) {
        if (response.statusCode != 200) {
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

          if (data['code'] == 1) {
            final snackBar = SnackBar(
              content: Text("A email has send to your Kean Email address"),
              backgroundColor: gwuBlue,
            );

            Scaffold.of(context)
                .showSnackBar(snackBar)
                .closed
                .then((SnackBarClosedReason reason) {
              Navigator.pop(context);
            });
          } else {
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
//          debugPrint("Response body: ${response.body}");
        }
      });
    }
  }
}
