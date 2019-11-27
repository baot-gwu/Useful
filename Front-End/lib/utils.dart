import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:useful/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:useful/colors.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;

saveUserInfo(userID, username, email, avatar, token, context) async {
//  debugPrint('Info: saveUserInfo');
  if (kIsWeb) {
//    debugPrint("$userID $username $email $avatar $token");
    html.window.localStorage['UC_user_id'] = userID.toString();
    html.window.localStorage['UC_username'] = username.toString();
    html.window.localStorage['UC_email'] = email.toString();
    html.window.localStorage['UC_avatar'] = avatar.toString();
    html.window.localStorage['UC_token'] = token.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('UC_user_id', userID);
    await prefs.setString('UC_username', username);
    await prefs.setString('UC_email', email);
    await prefs.setString('UC_avatar', avatar);
    await prefs.setString('UC_token', token);
  }
  await setGlobalUserInfo(context);
//  debugPrintUserInfo();
}

setGlobalUserInfo(context) async {
//  debugPrint('Info: setGlobalUserInfo');
  String _token = await getString('UC_token');
//  debugPrint('_token: $_token');
  int _loginStatus = await checkToken(_token);
//  debugPrint('checkToken; ' + _loginStatus.toString());

  if (_token == null || _loginStatus == -1) {
//    debugPrint(
//        '_token: ${_token.toString()}, _loginStatus = ${_loginStatus
//            .toString()}');
    await cleanData(context);
  } else {
//    if (_loginStatus == 1) {
//      await updateUserInfo(_token);
//    }
    var _globalUserID = await getInt('UC_user_id');

    if (_globalUserID != null) {
      globalUserID = await getInt('UC_user_id');
      globalUsername = await getString('UC_username');
      globalUserEmail = await getString('UC_email');
      globalUserAvatarUrl = await getString('UC_avatar');
      globalUserAvatar = (globalUserAvatarUrl == null)
          ? AssetImage('assets/avatar.png')
          : NetworkImage(globalUserAvatarUrl);
      globalUserToken = _token;
    }
  }
//  debugPrint('Debug: token: $globalUserToken');
}

updateUserInfo(token, context) async {
//  debugPrint('Info: updateUserInfo');
  await http.get(
    getMyInfoApi,
    headers: {'Authorization': "Bearer $token"},
  ).then((response) {
//    debugPrint(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      saveUserInfo(data['data']['id'], data['data']['username'],
          data['data']['email'], data['data']['avatarurl'], token, context);
    } else if (response.statusCode == 201) {
      final snackBar = SnackBar(
        content: Text('Your login status is expired'),
        backgroundColor: gwuBlue,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: gwuFlax,
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }).catchError((error) {
    final snackBar = SnackBar(
      content: Text('Please check your network connection'),
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

cleanData(context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
  globalUserID = null;
  globalUsername = null;
  globalUserEmail = null;
  globalUserToken = null;
  globalUserAvatarUrl = null;
  globalUserAvatar = null;
}

getForumList() async{
  Map<String, dynamic> data;
  await http.get(forumApi,
      headers: {'Authorization': 'Bearer $globalUserToken'}).then((response) {
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      for (int i = 0; i < (data['data']).length; i++) {
        forumDataName[(data['data'])[i]['name']] = (data['data'])[i];
        if ((data['data'])[i]['fid'] != 1)
          forumListsTabList.add(
              new Tab(icon: Icon(Icons.forum), text: (data['data'])[i]['name'].toString())
          );
      }
    } else if (response.statusCode == 201) {
      debugPrint('[ForumList Init]: Your login status is expired');
    } else if (!httpCodes.contains(response.statusCode)) {
      debugPrint('[ForumList Init]: Please check your network connection and try again later');
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      debugPrint('[ForumList Init]: ${data['msg']}');
    }
  }).catchError((error) {
    debugPrint('[ForumList Init]: $error');
  });
}

debugPrintUserInfo() {
  debugPrint('UserID: $globalUserID');
  debugPrint('Username: $globalUsername');
  debugPrint('UserEmail: $globalUserEmail');
  debugPrint('UserAvatar: $globalUserAvatarUrl');
  debugPrint('UserToken: $globalUserToken');
}

//setTasteList() {
//  List<String> _tasteTagList = [];
//  String tasteEnglishString = tasteToEnglish(globalUserTaste);
//  playlistTabList = [
//    Tab(icon: Icon(Icons.whatshot), text: 'Hot'),
//    Tab(icon: Icon(Icons.queue_music), text: 'My Playlist'),
//  ];
//
//  if (tasteEnglishString != 'Unknown') {
//    _tasteTagList = tasteEnglishString.split(',');
//
//    for (int i = 0; i < _tasteTagList.length; i++) {
//      playlistTabList
//          .add(Tab(icon: Icon(Icons.thumb_up), text: '${_tasteTagList[i]}'));
//    }
//
//    tasteEnglishString =
//        tasteEnglishString.substring(2, tasteEnglishString.length);
//  } else {
//    tasteEnglishString = 'Unknown';
//  }
//}

Future<int> checkToken(token) async {
  int result = 0;
  await http
      .get(getMyInfoApi,
          headers: {'Authorization': "Bearer $token"})
      .then((response) {
//    debugPrint(response.statusCode.toString());
//    debugPrint(response.body);
    if (response.statusCode == 200) {
      result = 1;
    } else if (response.statusCode == 401) {
      result = -1;
    } else {
      result = 0;
    }
  });
  return result;
}

Future<String> getString(keyword) async {
  var result;
  if (kIsWeb) {
    result = html.window.localStorage[keyword];
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getString(keyword);
  }

  return result;
}

Future<int> getInt(keyword) async {
  var result;
  if (kIsWeb) {
    result = int.parse(html.window.localStorage[keyword]);
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getInt(keyword);
  }
  return result;
}

Future<bool> getBool(keyword) async {
  var result;
  if (kIsWeb) {
    result = (html.window.localStorage[keyword] == "true") ? true : false;
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getBool(keyword);
  }
  return result;
}

Future<double> getDouble(keyword) async {
  var result;
  if (kIsWeb) {
    result = double.parse(html.window.localStorage[keyword]);
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getDouble(keyword);
  }
  return result;
}

Future<List<String>> getList(keyword) async {
  var result;
  if (kIsWeb) {
    result = html.window.localStorage[keyword];
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getStringList(keyword);
  }
  return result;
}

saveInt(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
}

saveString(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}

saveBool(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}

saveDouble(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }
}

saveList(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }
}
