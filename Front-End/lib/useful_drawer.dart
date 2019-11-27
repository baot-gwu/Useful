import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:useful/app.dart';
import 'package:useful/bootup.dart';
import 'package:useful/dev.dart';
import 'package:useful/forum_list.dart';
import 'package:useful/login.dart';
import 'package:useful/profile.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;

class UsefulDrawer extends StatefulWidget {
  @override
  _UsefulDrawerStatus createState() => new _UsefulDrawerStatus();
}

class _UsefulDrawerStatus extends State<UsefulDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: (globalUsername == null)
                ? Text('Click the avatar to Login')
                : Text(globalUsername),
            accountEmail: (globalUserEmail == null)
                ? Text('Please login to get the account information')
                : Text(globalUserEmail),
            currentAccountPicture: GestureDetector(
              onTap: () {
                if (globalUserID == null) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new LoginPage()));
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new ProfilePage()));
                }
              },
              child: ClipOval(
                child: SizedBox(
                  child: FadeInImage.assetNetwork(
                      placeholder: 'assets/avatar.png',
                      image: (globalUserAvatarUrl == null ||
                              globalUserAvatarUrl == "default.png")
                          ? defaultAvatarURL
                          : globalUserAvatarUrl),
                  width: 90.0,
                  height: 90.0,
                ),
              ),
            ),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                fit: BoxFit.fill,
                image: new ExactAssetImage('assets/background.jpg'),
              ),
            ),
          ),
          new ListTile(
            title: new Text('Forum'),
            leading: new Icon(Icons.forum),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ForumListPage()));
            },
          ),
          new ListTile(
              title: new Text('Dev Tool'),
              leading: new Icon(Icons.developer_mode),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => new DevPage()));
              }),
          new ListTile(
              title: new Text('Bootup'),
              leading: new Icon(Icons.developer_mode),
              onTap: () {
//                Navigator.of(context).pushNamed('/bootup');
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new BootUpPage()));
              }),
          new ListTile(
            title: (!kIsWeb) ? new Text('Close') : new Text('Get App'),
            leading: (!kIsWeb)
                ? new Icon(Icons.exit_to_app)
                : new Icon(Icons.get_app),
            onTap: (!kIsWeb)
                ? () async {
                    await pop();
                  }
                : () =>
                  html.window.open(appDownloadPage, 'Get Useful App'),
          )
        ],
      ),
    );
  }

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
