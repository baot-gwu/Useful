import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';
import 'colors.dart';
import 'app.dart';
import 'utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var mode = "normal";

  void _select(String value) {
    setState(() {
      mode = value;
    });
  }

  List<PopupMenuEntry> _getItemBuilder() {
    List<PopupMenuEntry<String>> list = List();
    if (mode == "normal") {
      list.add(PopupMenuItem(
        child: Text("Edit Profile"),
        value: "edit",
      ));
    } else {
      list.add(PopupMenuItem(
        child: Text("Quit edit mode"),
        value: "normal",
      ));
    }
    list.add(PopupMenuItem(
      child: Text("Logout"),
      value: "logout",
    ));
    return list;
  }

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
        title: Text('Profile'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return _getItemBuilder();
            },
          )
        ],
      ),
      body: (globalUserToken == null)
          ? SafeArea(
              child: Center(
                child: Text("Please Login in"),
              ),
            )
          : (mode == "normal")
              ? new ProfileInfo(
                  userID: globalUserID,
                  username: globalUsername,
                  email: globalUserEmail,
                  avatar: globalUserAvatarUrl,
                )
              : (mode == "edit") ? new EditProfileInfo() : new Logout(),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final int userID;
  final String username;
  final String email;
  final String avatar;

  const ProfileInfo({
    Key key,
    @required this.userID,
    @required this.username,
    @required this.email,
    @required this.avatar,
  })  : assert(userID != null),
        assert(username != null),
        assert(email != null),
        assert(avatar != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Image(
            image: AssetImage('assets/background.jpg'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(username),
            subtitle: Text('Username'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: new Text(email),
            subtitle: const Text('Email'),
          ),
        ],
      ),
    );
  }
}

class EditProfileInfo extends StatefulWidget {
  @override
  _EditProfileInfoState createState() => _EditProfileInfoState();
}

class _EditProfileInfoState extends State<EditProfileInfo> {
  var userID = globalUserID;
  var username = globalUsername;
  var email = globalUserEmail;
  var avatar = globalUserAvatarUrl;

  final _newUsernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Image(
            image: AssetImage('assets/background.jpg'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Current username: $username'),
          ),
          Container(
            margin: new EdgeInsets.only(left: 70.0, right: 40.0),
            child: AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _newUsernameController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Username (blank: keep origin)',
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Current email: $email'),
          ),
          Container(
            margin: new EdgeInsets.only(left: 70.0, right: 40.0),
            child: AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _newEmailController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Email (blank: keep origin)',
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Your password does store in this device'),
          ),
          Container(
            margin: new EdgeInsets.only(left: 70.0, right: 40.0),
            child: AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password (blank: keep origin)',
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: 40.0, right: 40.0, top: 30.0, bottom: 40.0),
            child: SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                child: Text('Update'),
                onPressed: () {
                  _profileSubmit(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _profileSubmit(context) {
    Map _updateData = new Map();

    if (_newUsernameController.text != '') {
      _updateData['username'] = _newUsernameController.text;
    }

    if (_newPasswordController.text != '') {
      _updateData['password'] = _newPasswordController.text;
    }

    if (_newEmailController.text != '') {
      _updateData['email'] = _newEmailController.text;
    }
//    debugPrint(_updateData.toString());

    if (_updateData.length != 0) {
      final snackBarUpdating = SnackBar(
        content: Text('Updating your profile...'),
        backgroundColor: gwuBlue,
      );
      Scaffold.of(context).showSnackBar(snackBarUpdating);
      http
          .put(userApi,
              headers: {'Authorization': "Bearer $globalUserToken"},
              body: json.encode(_updateData))
          .then((response) {
        if (response.statusCode != 200 || response.statusCode != 401) {
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
//          debugPrint(response.body);
          final Map<String, dynamic> data = json.decode(response.body);

          if (response.statusCode == 200) {
            updateUserInfo(globalUserToken, context);
            final snackBar = SnackBar(
              content: Text("Profile Updated"),
              backgroundColor: gwuBlue,
            );

            Scaffold.of(context)
                .showSnackBar(snackBar)
                .closed
                .then((SnackBarClosedReason reason) {
              setState(() {});
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
          debugPrint("Response body: ${response.body}");
        }
      });
    }
  }
}

class Logout extends StatefulWidget {
  @override
  LogoutState createState() => new LogoutState();
}

class LogoutState extends State<Logout> {
  int count = 3;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    ucBus.fire('logout');
    cleanData(context);
    _timer = new Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      if (count <= 0) {
        _timer.cancel();
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        count--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Text('Logout Successful!\nReturn to Homepage in $count seconds...'),
    );
  }
}
