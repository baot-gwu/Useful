import 'package:flutter/material.dart';
import 'package:useful/login.dart';
import 'package:useful/colors.dart';
import 'package:useful/profile.dart';
import 'package:useful/bootup.dart';
import 'package:useful/dev.dart';
import 'package:useful/useful_drawer.dart';
import 'package:useful/register.dart';
import 'package:useful/reset_password.dart';
import 'package:useful/forum_list.dart';
import 'package:useful/home.dart';
import 'package:useful/widget/thread.dart';
import 'package:event_bus/event_bus.dart';

// Add all the const and global vars here

int globalUserID;
//String globalUserName = 'Click the avatar to Login';
//String globalUserEmail = 'Please login to get the account information';
//ImageProvider globalUserAvatar = AssetImage('assets/avatar.png');
String globalUsername, globalUserEmail, globalUserToken, globalUserAvatarUrl;
ImageProvider globalUserAvatar;

List httpCodes = [200, 201, 400, 405, 409, 415];

final homeDomain = 'https://useful.baoziii.dev';
// API URIs
final apiDomain = "https://useful.baoziii.dev/api";

// User Center
final registerApi = apiDomain + '/register';
final loginApi = apiDomain + '/auth/token';
final getNewTokenApi = apiDomain + "/auth/token";
final resetPasswordApi = apiDomain + '/';
final getMyInfoApi = apiDomain + '/me';
final userApi = apiDomain + '/users';
final forumApi = apiDomain + '/forum';
final threadApi = '/thread';
final postApi = '/post';

final defaultImage = AssetImage('assets/imagePlaceHolder.png');
final defaultAvatarURL = homeDomain + '/static/image/avatar.png';
final imagePlaceHolder = 'assets/imagePlaceHolder.png';
final imagePlaceHolderURL = homeDomain + '/static/image/imagePlaceHolder.png';
final appDownloadPage = homeDomain + '/download/useful_v1_0_0.apk';

List<Tab> forumListsTabList = <Tab>[
  Tab(icon: Icon(Icons.warning), text: 'Bulletin'),
];
Map<String, dynamic> forumDataName = new Map();

EventBus ucBus = EventBus();
EventBus forumBus = EventBus();
EventBus threadBus = EventBus();

//final Icon_more = new Icon(
//  Theme
//      .of(context)
//      .platform == TargetPlatform.iOS
//      ? Icons.more_horiz
//      : Icons.more_vert,
//);

//final Icon_back = new Icon(
//  Theme
//      .of(context)
//      .platform == TargetPlatform.iOS
//      ? Icons.arrow_back_ios
//      : Icons.arrow_back,
//Icons.arrow_back,
//  semanticLabel: 'back',
//);

class UsefulApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Useful',
      initialRoute: '/bootup',
      routes: {
        '/': (BuildContext context) => new HomePage(),
        '/bootup': (BuildContext context) => new BootUpPage(),
        '/account/login': (BuildContext context) => new LoginPage(),
        '/account/profile': (BuildContext context) => new ProfilePage(),
        '/account/register': (BuildContext context) => new RegisterPage(),
        '/account/password': (BuildContext context) => new PasswordPage(),
        '/forum': (BuildContext context) => new ForumListPage(),
        '/forum/thread': (BuildContext context) => new ThreadPage(
            fid: 0,
            tid: 0,
            topic: "Loading",
            abstract: {"announcement": "", "shortMessage": ""},
            body: {"content": ""},
            author: {"id": 0, "username": "admin", "avatar": "default.png"},
            view: 0,
            reply: 0,
            updateTime: DateTime.now(),
            admins: [1],
            widgets: {}
            ),
        '/dev': (BuildContext context) => new DevPage(),
        '/widgets/drawer': (BuildContext context) => new UsefulDrawer(),
      },
      onGenerateRoute: _getRoute,
      theme: usefulTheme,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new HomePage(),
          fullscreenDialog: true,
        );
        break;
      case '/bootup':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new BootUpPage(),
          fullscreenDialog: true,
        );
        break;
      case '/account/login':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new LoginPage(),
          fullscreenDialog: true,
        );
        break;
      case '/account/profile':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new ProfilePage(),
          fullscreenDialog: true,
        );
        break;
      case '/account/register':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new RegisterPage(),
          fullscreenDialog: true,
        );
        break;
      case '/account/password':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new PasswordPage(),
          fullscreenDialog: true,
        );
        break;
      case '/forum':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new ForumListPage(),
          fullscreenDialog: true,
        );
        break;
      case '/forum/thread':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new ThreadPage(
            fid: 0,
            tid: 0,
            topic: "Loading",
            abstract: {"announcement": "", "shortMessage": ""},
            body: {"content": ""},
            author: {"id": 0, "username": "admin", "avatar": "default.png"},
            view: 0,
            reply: 0,
            updateTime: DateTime.now(),
            admins: [1],
            widgets: {}
            ),
          fullscreenDialog: true,
        );
        break;
      case '/dev':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new DevPage(),
          fullscreenDialog: true,
        );
        break;
      case '/widgets/drawer':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => new UsefulDrawer(),
          fullscreenDialog: false,
        );
        break;
      default:
        return null;
    }
  }
}
